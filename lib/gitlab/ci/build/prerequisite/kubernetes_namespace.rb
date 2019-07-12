# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Prerequisite
        class KubernetesNamespace < Base
          def unmet?
            deployment_cluster.present? &&
              deployment_cluster.managed? &&
              missing_namespace?
          end

          def complete!
            return unless unmet?

            create_or_update_namespace
          end

          private

          def missing_namespace?
            kubernetes_namespace.nil? || kubernetes_namespace.service_account_token.blank?
          end

          def deployment_cluster
            build.deployment&.cluster
          end

          def environment
            build.deployment.environment
          end

          def kubernetes_namespace
            strong_memoize(:kubernetes_namespace) do
              Clusters::KubernetesNamespaceFinder.new(
                deployment_cluster,
                project: environment.project,
                environment_slug: environment.slug,
                allow_blank_token: true
              ).execute
            end
          end

          def create_or_update_namespace
            Clusters::Gcp::Kubernetes::CreateOrUpdateNamespaceService.new(
              cluster: deployment_cluster,
              kubernetes_namespace: deployment_cluster.build_kubernetes_namespace(environment)
            ).execute
          end
        end
      end
    end
  end
end
