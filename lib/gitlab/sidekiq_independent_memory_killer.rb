# frozen_string_literal: true

module Gitlab
  class SidekiqIndependentMemoryKiller < Daemon
    include ::Gitlab::Utils::StrongMemoize # do not know whether we need this?

    # RSS below IDEAL_MAX_RSS is guaranteed to be safe
    IDEAL_MAX_RSS = (ENV['SIDEKIQ_MEMORY_KILLER_IDEAL_MAX_RSS'] || 0).to_s.to_i
    # RSS above HARD_LIMIT_MAX_RSS will be killed immediately
    HARD_LIMIT_MAX_RSS = (ENV['SIDEKIQ_MEMORY_KILLER_HARD_LIMIT_MAX_RSS'] || 0).to_s.to_i
    # RSS in range (IDEAL_MAX_RSS, HARD_LIMIT_MAX_RSS) will be allowed for ALLOW_RSS_BALLOON_TIME seconds
    # Sidekiq process will be kill if RSS is more than IDEAL_MAX_RSS for longer time than ALLOW_RSS_BALLOON_TIME
    ALLOW_RSS_BALLOON_SECONDS = (ENV['SIDEKIQ_MEMORY_KILLER_ALLOW_RSS_BALLOON_SECONDS'] || 15 * 60).to_s.to_i
    # Check RSS every CHECK_INTERVAL_SECONDS
    CHECK_INTERVAL_SECONDS = (ENV['SIDEKIQ_MEMORY_KILLER_CHECK_INTERVAL_SECONDS'] || 3).to_s.to_i
    # Wait 30 seconds for running jobs to finish during graceful shutdown
    SHUTDOWN_WAIT = (ENV['SIDEKIQ_MEMORY_KILLER_SHUTDOWN_WAIT'] || 30).to_s.to_i

    attr_accessor :sidekiq_worker_pid
    attr_reader :rss_balloon_started_time

    def initialize
      super

      reset_rss_balloon_started_time
    end

    private

    attr_writer :rss_balloon_started_time

    def reset_rss_balloon_started_time
      self.rss_balloon_started_time = nil
    end

    def start_working
      Sidekiq.logger.info(
        class: self.class.to_s,
        action: 'start',
        message: "Starting SidekiqIndependentMemoryKiller Daemon. sidekiq_worker_pid: #{sidekiq_worker_pid}"
      )

      while enabled?
        check_rss
        sleep(CHECK_INTERVAL_SECONDS)
      end
    rescue StandardError => e
      Sidekiq.logger.warn( e.message )
      Sidekiq.logger.warn(
        class: self.class.to_s,
        action: 'stop',
        message: 'Stopping SidekiqIndependentMemoryKiller Daemon'
      )
    end

    def check_rss
      Sidekiq.logger.info(
        class: self.class.to_s,
        action: 'check_rss',
        message: "Checking RSS for Sidekiq worker pid(#{sidekiq_worker_pid}"
      )

      current_rss = get_rss

      if HARD_LIMIT_MAX_RSS > 0 && current_rss > HARD_LIMIT_MAX_RSS
        hard_limit_kill(current_rss)
      elsif IDEAL_MAX_RSS > 0
        check_balloon_limit_kill(current_rss)
      end
    end

    def check_balloon_limit_kill(current_rss)
      if current_rss < IDEAL_MAX_RSS
        reset_rss_balloon_started_time
        return
      end

      now = Time.now.to_i
      if rss_balloon_started_time.nil?
        self.rss_balloon_started_time = now
      end

      balloon_seconds = now - rss_balloon_started_time

      if balloon_seconds < ALLOW_RSS_BALLOON_SECONDS
        Sidekiq.logger.warn(
          class: self.class.to_s,
          message: "Sidekiq worker PID-#{sidekiq_worker_pid} current RSS #{current_rss}"\
          " exceeds IDEAL_MAX_RSS #{IDEAL_MAX_RSS}"\
          " but balloon_seconds #{balloon_seconds}"\
          " is shorter than ALLOW_RSS_BALLOON_SECONDS #{ALLOW_RSS_BALLOON_SECONDS}"
        ) # todo: we may not need to log every check
      elsif balloon_seconds > ALLOW_RSS_BALLOON_SECONDS
        Sidekiq.logger.warn(
          class: self.class.to_s,
          message: "Sidekiq worker PID-#{sidekiq_worker_pid} current RSS #{current_rss}"\
          " exceeds IDEAL_MAX_RSS #{IDEAL_MAX_RSS}"\
          " and balloon_seconds #{balloon_seconds}"\
          " is longer than ALLOW_RSS_BALLOON_SECONDS #{ALLOW_RSS_BALLOON_SECONDS}"
        )

        # wait_and_signal(SHUTDOWN_WAIT, 'SIGTERM', 'gracefully shut down') # should we use SIGKILL?
        wait_and_signal(SHUTDOWN_WAIT, 'SIGKILL', 'forced shut down')

        reset_rss_balloon_started_time
      end
    end

    def hard_limit_kill(current_rss)
      if current_rss > HARD_LIMIT_MAX_RSS
        Sidekiq.logger.warn(
          class: self.class.to_s,
          message: "Sidekiq worker PID-#{sidekiq_worker_pid} current RSS #{current_rss}"\
               " exceeds HARD_LIMIT_MAX_RSS #{HARD_LIMIT_MAX_RSS}"
        )

        wait_and_signal(0, 'SIGTERM', 'Terminate immediately') # should we use SIGKILL?
      end
    end

    def get_rss
      output, status = Gitlab::Popen.popen(%W(ps -o rss= -p #{sidekiq_worker_pid}), Rails.root.to_s)
      return 0 unless status.zero?

      output.to_i
    end

    def wait_and_signal(time, signal, explanation)
      Sidekiq.logger.warn("waiting #{time} seconds before sending Sidekiq worker PID-#{sidekiq_worker_pid} #{signal} (#{explanation})")
      sleep(time)

      Sidekiq.logger.warn("sending Sidekiq worker PID-#{sidekiq_worker_pid} #{signal} (#{explanation})")
      Process.kill(signal, sidekiq_worker_pid)
    end

    def stop_working
      Sidekiq.logger.info(
        class: self.class.to_s,
        action: 'stop',
        message: 'Stopping SidekiqIndependentMemoryKiller Daemon'
      )
    end
  end
end
