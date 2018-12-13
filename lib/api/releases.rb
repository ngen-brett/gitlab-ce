# frozen_string_literal: true

module API
  class Releases < Grape::API
    include PaginationParams

    TAG_ENDPOINT_REQUIREMENTS = API::NAMESPACE_OR_PROJECT_REQUIREMENTS.merge(tag_name: API::NO_SLASH_URL_PART_REGEX)

    before { error!('404 Not Found', 404) unless Feature.enabled?(:releases_page) }
    before { authorize! :download_code, user_project }

    params do
      requires :id, type: String, desc: 'The ID of a project'
    end
    resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      desc 'Get a project releases' do
        detail 'This feature was introduced in GitLab 11.7.'
        success Entities::Release
      end
      params do
        use :pagination
      end
      get ':id/releases' do
        releases = ::Kaminari.paginate_array(user_project.releases)

        present paginate(releases), with: Entities::Release
      end

      desc 'Get a single project release' do
        detail 'This feature was introduced in GitLab 11.7.'
        success Entities::Release
      end
      params do
        requires :tag_name, type: String, desc: 'The name of the tag'
      end
      get ':id/releases/:tag_name', requirements: TAG_ENDPOINT_REQUIREMENTS do
        release = user_project.releases.find_by_tag(params[:tag_name])
        not_found!('Release') unless release

        present release, with: Entities::Release
      end

      desc 'Create a new release' do
        detail 'This feature was introduced in GitLab 11.7.'
        success Entities::Release
      end
      params do
        requires :name,                type: String, desc: 'The name of the release'
        requires :tag_name,            type: String, desc: 'The name of the tag'
        requires :description,         type: String, desc: 'The release notes'
        optional :ref,                 type: String, desc: 'The commit sha or branch name'
      end
      post ':id/releases' do
        authorize_push_project

        result = ::CreateReleaseService.new(user_project, current_user)
          .execute(params[:tag_name], params[:description], params[:name], params[:ref])

        if result[:status] == :success
          present result[:release], with: Entities::Release
        else
          render_api_error!(result[:message], 400)
        end
      end

      desc 'Update a release' do
        detail 'This feature was introduced in GitLab 11.7.'
        success Entities::Release
      end
      params do
        requires :tag_name,    type: String, desc: 'The name of the tag'
        requires :description, type: String, desc: 'Release notes with markdown support'
      end
      put ':id/releases/:tag_name', requirements: TAG_ENDPOINT_REQUIREMENTS do
        authorize_push_project

        result = UpdateReleaseService.new(user_project, current_user)
          .execute(params[:tag_name], params[:description])

        if result[:status] == :success
          present result[:release], with: Entities::Release
        else
          render_api_error!(result[:message], result[:http_status])
        end
      end
    end
  end
end
