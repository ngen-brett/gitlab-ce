# frozen_string_literal: true

module Gitlab
  module Metrics
    module Samplers
      class UnicornSampler < BaseSampler
        def initialize(interval)
          super(interval)
        end

        def unicorn_active_connections
          @unicorn_active_connections ||= ::Gitlab::Metrics.gauge(:unicorn_active_connections, 'Unicorn active connections', {}, :max)
        end

        def unicorn_queued_connections
          @unicorn_queued_connections ||= ::Gitlab::Metrics.gauge(:unicorn_queued_connections, 'Unicorn queued connections', {}, :max)
        end

        def process_cpu_seconds_total_gauge
          @process_cpu_seconds_total ||= ::Gitlab::Metrics.gauge(:process_cpu_seconds_total, 'Process CPU seconds total', {})
        end

        def process_start_time_seconds_gauge
          @process_start_time_seconds ||= ::Gitlab::Metrics.gauge(:process_start_time_seconds, 'Process start time seconds', {})
        end

        def process_max_fds_gauge
          @process_max_fds ||= ::Gitlab::Metrics.gauge(:process_max_fds, 'Process max fds', {})
        end

        def unicorn_workers_count
          @unicorn_workers ||= ::Gitlab::Metrics.count(:unicorn_workers, 'Unicorn workers', {})
        end

        def enabled?
          # Raindrops::Linux.tcp_listener_stats is only present on Linux
          unicorn_with_listeners? && Raindrops::Linux.respond_to?(:tcp_listener_stats)
        end

        def sample
          Raindrops::Linux.tcp_listener_stats(tcp_listeners).each do |addr, stats|
            unicorn_active_connections.set({ socket_type: 'tcp', socket_address: addr }, stats.active)
            unicorn_queued_connections.set({ socket_type: 'tcp', socket_address: addr }, stats.queued)
          end

          Raindrops::Linux.unix_listener_stats(unix_listeners).each do |addr, stats|
            unicorn_active_connections.set({ socket_type: 'unix', socket_address: addr }, stats.active)
            unicorn_queued_connections.set({ socket_type: 'unix', socket_address: addr }, stats.queued)
          end

          ps = Sys::ProcTable.ps(pid: pid)
          process_cpu_seconds_total_gauge.set({ worker: pid }, process_cpu_seconds_total(ps))
          process_start_time_seconds_gauge.set({ worker: pid }, process_start_time_seconds(ps))
          process_max_fds_gauge.set({ worker: pid }, process_max_fds)
          unicorn_workers_count.set({}, unix_listeners.count)
        end

        private

        def tcp_listeners
          @tcp_listeners ||= Unicorn.listener_names.grep(%r{\A[^/]+:\d+\z})
        end

        def pid
          @pid ||= Process.pid
        end

        def process_cpu_seconds_total(ps)
          (ps.stime + ps.utime) / 100
        end

        def process_start_time_seconds(ps)
          @process_start_time_seconds ||= ps.starttime / 100
        end

        def process_max_fds
          @process_max_fds_gauge ||= File.open('/proc/self/limits').match(/Max open files\s*(\d+)/)
        end

        def unix_listeners
          @unix_listeners ||= Unicorn.listener_names - tcp_listeners
        end

        def unicorn_with_listeners?
          defined?(Unicorn) && Unicorn.listener_names.any?
        end
      end
    end
  end
end
