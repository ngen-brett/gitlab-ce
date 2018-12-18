# frozen_string_literal: true

module API
  class ProjectClusters < Grape::API
    include PaginationParams

    before { authenticate! }

    params do
      requires :id, type: String, desc: 'The ID of the project'
    end
    resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      desc 'Get all clusters from the project' do
        detail 'This feature was introduced in GitLab 11.7.'
        success Entities::Cluster
      end
      params do
        use :pagination
      end
      get ':id/clusters' do
        authorize! :read_cluster, user_project

        present paginate(clusters_for_current_user), with: Entities::Cluster
      end

      desc 'Gets a specific cluster for the project' do
        detail 'This feature was introduced in GitLab 11.7.'
        success Entities::Cluster
      end
      params do
        requires :cluster_id, type: Integer, desc: 'The cluster ID'
      end
      get ':id/clusters/:cluster_id' do
        authorize! :read_cluster, user_project

        present cluster, with: Entities::Cluster
      end

      desc 'Create a new cluster' do
      end

      desc 'Update an existing cluster' do
      end

      desc 'Remove a cluster' do
      end
    end

    helpers do
      def clusters_for_current_user
        ClustersFinder.new(user_project, current_user, :all).execute
      end

      def cluster
        @cluster ||= clusters_for_current_user.find(params[:cluster_id])
      end
    end
  end
end
