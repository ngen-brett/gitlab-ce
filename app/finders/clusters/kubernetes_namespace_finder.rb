# frozen_string_literal: true

module Clusters
  class KubernetesNamespaceFinder
    attr_reader :cluster, :project, :environment_slug

    def initialize(cluster, project:, environment_slug:, allow_blank_token: false)
      @cluster = cluster
      @project = project
      @environment_slug = environment_slug
      @allow_blank_token = allow_blank_token
    end

    def execute
      # These fallbacks are to prevent changes in behaviour
      # if the :kubernetes_namespace_per_environment feature
      # flag is disabled and re-enabled (or vice versa). When
      # the feature flag is removed we can remove these too.
      if cluster.namespace_per_environment?
        find_namespace_for_environment || find_namespace
      else
        find_namespace || find_namespace_for_environment
      end
    end

    private

    attr_reader :allow_blank_token

    def find_namespace_for_environment
      find_namespace(environment_slug: environment_slug)
    end

    def find_namespace(environment_slug: nil)
      attributes = { project: project, environment_slug: environment_slug }
      attributes[:cluster_project] = cluster.cluster_project if cluster.project_type?

      namespaces.find_by(attributes) # rubocop: disable CodeReuse/ActiveRecord
    end

    def namespaces
      if allow_blank_token
        cluster.kubernetes_namespaces
      else
        cluster.kubernetes_namespaces.has_service_account_token
      end
    end
  end
end
