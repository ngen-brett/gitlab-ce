# frozen_string_literal: true

module Clusters
  module Applications
    class CheckIngressService < BaseHelmService
      include Gitlab::Utils::StrongMemoize

      Error = Class.new(StandardError)

      LEASE_TIMEOUT = 15.seconds.to_i

      def execute
        return if app.external_ip
        return if app.external_hostname
        return unless try_obtain_lease

        app.update!(external_ip: ingress_ip) if ingress_ip
        app.update!(external_hostname: ingress_hostname) if ingress_hostname
      end

      private

      def try_obtain_lease
        Gitlab::ExclusiveLease
          .new("check_ingress_service:#{app.id}", timeout: LEASE_TIMEOUT)
          .try_obtain
      end

      def ingress_ip
        service.status.loadBalancer.ingress&.first&.ip
      end

      def ingress_hostname
        service.status.loadBalancer.ingress&.first&.hostname
      end

      def service
        strong_memoize(:ingress_service) do
          app.ingress_service
        end
      end
    end
  end
end
