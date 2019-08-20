# frozen_string_literal: true

module Gitlab
  class SidekiqMonitor < Daemon
    include ::Gitlab::Utils::StrongMemoize

    NOTIFICATION_CHANNEL = 'sidekiq:cancel:notifications'.freeze
    CANCEL_DEADLINE = 24.hours.seconds

    # We use exception derived from `Exception`
    # to consider this as an very low-level exception
    # that should not be caught by application
    CancelledError = Class.new(Exception) # rubocop:disable Lint/InheritException

    attr_reader :jobs_thread
    attr_reader :jobs_mutex

    def initialize
      super

      @jobs_thread = {}
      @jobs_mutex = Mutex.new
    end

    def within_job(jid, queue)
      jobs_mutex.synchronize do
        jobs_thread[jid] = Thread.current
      end

      if cancelled?(jid)
        Sidekiq.logger.warn(
          class: self.class,
          action: 'run',
          queue: queue,
          jid: jid,
          canceled: true)
        raise CancelledError
      end

      yield
    ensure
      jobs_mutex.synchronize do
        jobs_thread.delete(jid)
      end
    end

    def start_working
      Sidekiq.logger.info(
        class: self.class,
        action: 'start',
        message: 'Starting Monitor Daemon')

      ::Gitlab::Redis::SharedState.with do |redis|
        redis.subscribe(NOTIFICATION_CHANNEL) do |on|
          on.message do |channel, message|
            process_message(message)
          end
        end
      end

      Sidekiq.logger.warn(
        class: self.class,
        action: 'stop',
        message: 'Stopping Monitor Daemon')
    rescue Exception => e # rubocop:disable Lint/RescueException
      Sidekiq.logger.warn(
        class: self.class,
        action: 'exception',
        message: e.message)
      raise e
    end

    def self.cancel_job(jid)
      payload = {
        action: 'cancel',
        jid: jid
      }.to_json

      ::Gitlab::Redis::SharedState.with do |redis|
        redis.setex(cancel_job_key(jid), CANCEL_DEADLINE, 1)
        redis.publish(NOTIFICATION_CHANNEL, payload)
      end
    end

    private

    def process_message(message)
      Sidekiq.logger.info(
        class: self.class,
        channel: NOTIFICATION_CHANNEL,
        message: 'Received payload on channel',
        payload: message)

      message = safe_parse(message)
      return unless message

      case message['action']
      when 'cancel'
        process_job_cancel(message['jid'])
      else
        # unknown message
      end
    end

    def safe_parse(message)
      JSON.parse(message)
    rescue JSON::ParserError
    end

    def process_job_cancel(jid)
      return unless jid

      # since this might take time, process cancel in a new thread
      Thread.new do
        find_thread(jid) do |thread|
          next unless thread

          Sidekiq.logger.warn(
            class: self.class,
            action: 'cancel',
            message: 'Canceling thread with CancelledError',
            jid: jid,
            thread_id: thread.object_id)

          thread&.raise(CancelledError)
        end
      end
    end

    # This method needs to be thread-safe
    # This is why it passes thread in block,
    # to ensure that we do process this thread
    def find_thread(jid)
      return unless jid

      jobs_mutex.synchronize do
        thread = jobs_thread[jid]
        yield(thread)
        thread
      end
    end

    def cancelled?(jid)
      ::Gitlab::Redis::SharedState.with do |redis|
        redis.exists(self.class.cancel_job_key(jid))
      end
    end

    def self.cancel_job_key(jid)
      "sidekiq:cancel:#{jid}"
    end
  end
end
