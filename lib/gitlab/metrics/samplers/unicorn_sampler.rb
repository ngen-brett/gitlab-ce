# frozen_string_literal: true

module Gitlab
  module Metrics
    module Samplers
      class UnicornSampler < BaseSampler
        def initialize(interval)
          super(interval)
        end

        def metrics
          @metrics ||= init_metrics
        end

        def init_metrics
          {
            unicorn_active_connections: ::Gitlab::Metrics.gauge(:unicorn_active_connections, 'Unicorn active connections', {}, :max),
            unicorn_queued_connections: ::Gitlab::Metrics.gauge(:unicorn_queued_connections, 'Unicorn queued connections', {}, :max),
            unicorn_workers:            ::Gitlab::Metrics.gauge(:unicorn_workers, 'Unicorn workers'),
            process_cpu_seconds_total:  ::Gitlab::Metrics.gauge(:process_cpu_seconds_total, 'Process CPU seconds total'),
            process_max_fds:            ::Gitlab::Metrics.gauge(:process_max_fds, 'Process max fds'),
            process_start_time_seconds: ::Gitlab::Metrics.gauge(:process_start_time_seconds, 'Process start time seconds'),
          }
        end

        def enabled?
          # Raindrops::Linux.tcp_listener_stats is only present on Linux
          unicorn_with_listeners? && Raindrops::Linux.respond_to?(:tcp_listener_stats)
        end

        def sample
          Raindrops::Linux.tcp_listener_stats(tcp_listeners).each do |addr, stats|
            metrics[:unicorn_active_connections].set({ socket_type: 'tcp', socket_address: addr }, stats.active)
            metrics[:unicorn_queued_connections].set({ socket_type: 'tcp', socket_address: addr }, stats.queued)
          end

          Raindrops::Linux.unix_listener_stats(unix_listeners).each do |addr, stats|
            metrics[:unicorn_active_connections].set({ socket_type: 'unix', socket_address: addr }, stats.active)
            metrics[:unicorn_queued_connections].set({ socket_type: 'unix', socket_address: addr }, stats.queued)
          end

          ps = Sys::ProcTable.ps(pid: pid)
          metrics[:process_cpu_seconds_total].set({ pid: nil }, process_cpu_seconds_total(ps)) # pid gets set later by Prometheus config pid_provider
          metrics[:process_start_time_seconds].set({ pid: nil }, process_start_time_seconds(ps))
          metrics[:process_max_fds].set({ pid: nil }, process_max_fds)
          metrics[:unicorn_workers].set({}, unicorn_workers_count)
        end

        private

        def tcp_listeners
          @tcp_listeners ||= Unicorn.listener_names.grep(%r{\A[^/]+:\d+\z})
        end

        def pid
          @pid ||= Process.pid
        end

        def process_cpu_seconds_total(ps)
          (ps.stime + ps.utime) / 100.0
        end

        def process_max_fds
          @process_max_fds ||= begin 
            match = File.read('/proc/self/limits').match(/Max open files\s*(\d+)/)
            match ? match[1].to_i : nil
          end
        end

        def process_start_time_seconds(ps)
          @process_start_time_seconds ||= ps.starttime / 100.0
        end

        def unix_listeners
          @unix_listeners ||= Unicorn.listener_names - tcp_listeners
        end

        def unicorn_with_listeners?
          defined?(Unicorn) && Unicorn.listener_names.any?
        end

        def unicorn_workers_count
          Sys::ProcTable.ps.select {|p| p.cmdline.match(/unicorn_rails worker/)}.count
        end
      end
    end
  end
end
