# frozen_string_literal: true

module Gitlab
  module Metrics
    module Samplers
      class SidekiqSampler < BaseSampler
        def init_metrics
          {
            sidekiq_jobs_started_total: ::Gitlab::Metrics.gauge(:sidekiq_jobs_started_total, 'Sidekiq jobs started'),
            sidekiq_jobs_failed_total:  ::Gitlab::Metrics.gauge(:sidekiq_jobs_failed_total, 'Sidekiq jobs failed')
          }
        end

        def metrics
          @metrics ||= init_metrics
        end

        def sample
          stats = Sidekiq::Stats.new

          metrics[:sidekiq_jobs_started_total].set({}, stats.processed)
          metrics[:sidekiq_jobs_failed_total].set({}, stats.failed)
        end
      end
    end
  end
end
