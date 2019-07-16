# frozen_string_literal: true

module API
  class GroupContainerRepositories < Grape::API
    include PaginationParams

    before { authorize_read_group_container_images! }

    REPOSITORY_ENDPOINT_REQUIREMENTS = API::NAMESPACE_OR_PROJECT_REQUIREMENTS.merge(
      tag_name: API::NO_SLASH_URL_PART_REGEX)

    params do
      requires :id, type: String, desc: "Namespace's ID or path"
    end
    resource :groups, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      desc 'Get a list of all repositories and their tags within a group' do
        detail 'This feature was introduced in GitLab 12.2.'
        success Entities::ContainerRegistry::Repository
      end
      params do
        use :pagination
      end
      get ':id/registry/repositories/tags' do
        repositories = ContainerRepository.all.in_group(user_group).ordered

        present paginate(repositories), with: Entities::ContainerRegistry::RepositoryWithTags
      end

      desc 'Get a list of all repositories within a group' do
        detail 'This feature was introduced in GitLab 12.2.'
        success Entities::ContainerRegistry::Repository
      end
      params do
        use :pagination
      end
      get ':id/registry/repositories' do
        repositories = ContainerRepository.all.in_group(user_group).ordered

        present paginate(repositories), with: Entities::ContainerRegistry::Repository
      end
    end

    helpers do
      def authorize_read_group_container_images!
        authorize! :read_container_image, user_group
      end
    end
  end
end
