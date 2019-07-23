# frozen_string_literal: true

module Gitlab
  module SidekiqMiddleware
    class Metrics
      def initialize
        @metrics = init_metrics
      end

      def call(worker, job, queue)
        benchmark = Benchmark.measure do
          yield
        end

        @metrics[:sidekiq_jobs_completion_seconds].observe(labels(queue).merge(type: "user"), benchmark.utime + benchmark.cutime)
        @metrics[:sidekiq_jobs_completion_seconds].observe(labels(queue).merge(type: "system"), benchmark.stime + benchmark.cstime)
        @metrics[:sidekiq_jobs_completion_seconds].observe(labels(queue).merge(type: "real"), benchmark.real)
      end

      private

      def init_metrics
        {
          sidekiq_jobs_completion_seconds: ::Gitlab::Metrics.histogram(:sidekiq_jobs_completion_seconds, "Seconds to complete sidekiq job")
        }
      end

      def labels(queue)
        {
          queue: queue
        }
      end
    end
  end
end
