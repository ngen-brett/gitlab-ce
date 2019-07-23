# frozen_string_literal: true

module Gitlab
  module Metrics
    module Samplers
      class SidekiqSampler < BaseSampler
        def init_metrics
          {
            sidekiq_jobs_started_total: ::Gitlab::Metrics.counter(:sidekiq_jobs_started_total, 'Sidekiq jobs started'),
            sidekiq_jobs_failed_total:  ::Gitlab::Metrics.counter(:sidekiq_jobs_failed_total, 'Sidekiq jobs failed')
          }
        end

        def metrics
          @metrics ||= init_metrics
        end

        def sample
          old_sidekiq_jobs_started_total = metrics[:sidekiq_jobs_started_total].get
          old_sidekiq_jobs_failed_total = metrics[:sidekiq_jobs_failed_total].get

          stats = Sidekiq::Stats.new

          metrics[:sidekiq_jobs_started_total].increment({}, stats.processed - old_sidekiq_jobs_started_total)
          metrics[:sidekiq_jobs_failed_total].increment({}, stats.failed - old_sidekiq_jobs_failed_total)
        end
      end
    end
  end
end
