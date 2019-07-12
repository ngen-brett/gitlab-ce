# frozen_string_literal: true

module Clusters
  class RefreshService
    def self.create_or_update_namespaces_for_cluster(cluster)
      projects_with_missing_kubernetes_namespaces_for_cluster(cluster).each do |project|
        create_or_update_namespace(cluster, project)
      end
    end

    def self.create_or_update_namespaces_for_project(project)
      clusters_with_missing_kubernetes_namespaces_for_project(project).each do |cluster|
        create_or_update_namespace(cluster, project)
      end
    end

    def self.projects_with_missing_kubernetes_namespaces_for_cluster(cluster)
      cluster.all_projects.missing_kubernetes_namespace(cluster.kubernetes_namespaces)
    end

    private_class_method :projects_with_missing_kubernetes_namespaces_for_cluster

    def self.clusters_with_missing_kubernetes_namespaces_for_project(project)
      project.clusters.managed.missing_kubernetes_namespace(project.kubernetes_namespaces)
    end

    private_class_method :clusters_with_missing_kubernetes_namespaces_for_project

    def self.create_or_update_namespace(cluster, project)
      # This code isn't called from anywhere, and will be removed in
      # https://gitlab.com/gitlab-org/gitlab-ce/issues/59319
      kubernetes_namespace = Clusters::KubernetesNamespaceFinder.new(
        cluster,
        project: project,
        environment_slug: project.default_environment&.slug,
        allow_blank_token: true
      ).execute

      ::Clusters::Gcp::Kubernetes::CreateOrUpdateNamespaceService.new(
        cluster: cluster,
        kubernetes_namespace: kubernetes_namespace || cluster.build_kubernetes_namespace(project.default_environment)
      ).execute
    end

    private_class_method :create_or_update_namespace
  end
end
