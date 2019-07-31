# frozen_string_literal: true

require 'prometheus/client/support/unicorn'

module Gitlab
  module Metrics
    module Samplers
      class RubySampler < BaseSampler
        GC_REPORT_BUCKETS = [0.001, 0.002, 0.005, 0.01, 0.05, 0.1, 0.5].freeze

        def initialize(interval)
          GC::Profiler.clear
          @last_gc_stat_count = GC.stat[:count]

          metrics[:process_start_time_seconds].set(labels, Time.now.to_i)

          super
        end

        def metrics
          @metrics ||= init_metrics
        end

        def with_prefix(prefix, name)
          "ruby_#{prefix}_#{name}".to_sym
        end

        def to_doc_string(name)
          name.to_s.humanize
        end

        def labels
          {}
        end

        def init_metrics
          metrics = {
            file_descriptors:               ::Gitlab::Metrics.gauge(with_prefix(:file, :descriptors), 'File descriptors used', labels),
            memory_bytes:                   ::Gitlab::Metrics.gauge(with_prefix(:memory, :bytes), 'Memory used', labels),
            process_cpu_seconds_total:      ::Gitlab::Metrics.gauge(with_prefix(:process, :cpu_seconds_total), 'Process CPU seconds total'),
            process_max_fds:                ::Gitlab::Metrics.gauge(with_prefix(:process, :max_fds), 'Process max fds'),
            process_resident_memory_bytes:  ::Gitlab::Metrics.gauge(with_prefix(:process, :resident_memory_bytes), 'Memory used', labels),
            process_start_time_seconds:     ::Gitlab::Metrics.gauge(with_prefix(:process, :start_time_seconds), 'Process start time seconds'),
            sampler_duration:               ::Gitlab::Metrics.counter(with_prefix(:sampler, :duration_seconds_total), 'Sampler time', labels),
            gc_cycle_time:                  ::Gitlab::Metrics.histogram(with_prefix(:gc, :cycle_seconds), 'GC time', labels, GC_REPORT_BUCKETS),
            gc_missed_cycles:               ::Gitlab::Metrics.counter(with_prefix(:gc, :missed_cycles), 'Missed GC cycles', labels)
          }

          GC.stat.keys.each do |key|
            metrics[key] = ::Gitlab::Metrics.gauge(with_prefix(:gc_stat, key), to_doc_string(key), labels)
          end

          metrics
        end

        def sample
          start_time = System.monotonic_time

          metrics[:file_descriptors].set(labels, System.file_descriptor_count)
          metrics[:process_cpu_seconds_total].set(labels, ::Gitlab::Metrics::System.cpu_time)
          metrics[:process_max_fds].set(labels, ::Gitlab::Metrics::System.max_open_file_descriptors)
          set_memory_usage_metrics
          sample_gc

          metrics[:sampler_duration].increment(labels, System.monotonic_time - start_time)
        end

        private

        def sample_gc
          ### TODO: debug print
          p "--> #SAMPLE_GC"
          p "--> PROFILER DISABLED!" unless GC::Profiler.enabled?
          ###

          GC::Profiler.enable

          gc_reports = sample_gc_reports
          gc_stat = GC.stat

          ### TODO: debug print
          tmp_missed_cycles = gc_stat[:count] - @last_gc_stat_count - gc_reports.size
          p "--> MISSED_CYCLES: #{tmp_missed_cycles}"
          ###

          # Get a number of missed GC samples
          metrics[:gc_missed_cycles].increment(labels,
            gc_stat[:count] - @last_gc_stat_count - gc_reports.size)
          @last_gc_stat_count = gc_stat[:count]

          # Collect generic GC stats.
          gc_stat.each do |key, value|
            metrics[key].set(labels, value)
          end

          # Observe all GC samples
          gc_reports.each do |report|
            # TODO: debug print
            p "---> report[:GC_TIME]=#{report[:GC_TIME]}"
            metrics[:gc_cycle_time].observe(labels, report[:GC_TIME])
          end
        end

        def sample_gc_reports
          GC::Profiler.raw_data
        ensure
          GC::Profiler.clear
        end

        def set_memory_usage_metrics
          memory_usage = System.memory_usage

          metrics[:memory_bytes].set(labels, memory_usage)
          metrics[:process_resident_memory_bytes].set(labels, memory_usage)
        end
      end
    end
  end
end
