# frozen_string_literal: true

module Gitlab
  module SidekiqMiddleware
    class Metrics
      def initialize
        @metrics = init_metrics
      end

      def call(worker, job, queue)
        labels = create_labels(queue)
        @metrics[:sidekiq_jobs_started_total].increment(labels, 1)

        if job['retry_count'].present?
          @metrics[:sidekiq_jobs_retried_total].increment(labels, 1)
        end

        benchmark = Benchmark.measure do
          yield
        end

        @metrics[:sidekiq_jobs_completion_seconds].observe(labels.merge(type: 'user'), benchmark.utime + benchmark.cutime)
        @metrics[:sidekiq_jobs_completion_seconds].observe(labels.merge(type: 'system'), benchmark.stime + benchmark.cstime)
        @metrics[:sidekiq_jobs_completion_seconds].observe(labels.merge(type: 'real'), benchmark.real)
      rescue Exception # rubocop: disable Lint/RescueException
        @metrics[:sidekiq_jobs_failed_total].increment(labels, 1)
        raise
      end

      private

      def init_metrics
        {
          sidekiq_jobs_completion_seconds: ::Gitlab::Metrics.histogram(:sidekiq_jobs_completion_seconds, 'Seconds to complete sidekiq job'),
          sidekiq_jobs_failed_total:       ::Gitlab::Metrics.counter(:sidekiq_jobs_failed_total, 'Sidekiq jobs failed'),
          sidekiq_jobs_retried_total:      ::Gitlab::Metrics.counter(:sidekiq_jobs_retried_total, 'Sidekiq jobs retried'),
          sidekiq_jobs_started_total:      ::Gitlab::Metrics.counter(:sidekiq_jobs_started_total, 'Sidekiq jobs started')
        }
      end

      def create_labels(queue)
        {
          queue: queue
        }
      end
    end
  end
end
