# frozen_string_literal: true

module Gitlab
  module SidekiqMiddleware
    class Metrics
      def call(worker, job, queue)
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        yield

        end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        Gitlab::Metrics.histogram(:sidekiq_jobs_completion_time, "Time to complete sidekiq job").observe(labels(worker), end_time - start_time)
        Gitlab::Metrics.histogram(:sidekiq_jobs_memory_allocated_bytes, "Memory allocted for job in bytes").observe(labels(worker), get_rss)
      end

      private

      def get_rss
        output, status = Gitlab::Popen.popen(%W(ps -o rss= -p #{pid}), Rails.root.to_s)
        return 0 unless status.zero?

        output.to_i
      end

      def pid
        Process.pid
      end

      def labels(worker)
        {
          class: worker.class.to_s
        }
      end
    end
  end
end
