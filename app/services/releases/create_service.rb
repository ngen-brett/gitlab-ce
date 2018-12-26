# frozen_string_literal: true

module Releases
  class CreateService < BaseService
    include Releases::Concerns

    def execute
      return error('Access Denied', 403) unless allowed?
      return error('Release already exists', 409) if release

      new_tag = nil

      unless tag_exist?
        return error('Ref is not specified', 422) unless ref

        result = create_tag

        if result[:status] == :success
          new_tag = result[:tag]
        else
          return result
        end
      end

      create_release(existing_tag || new_tag)
    end

    private

    def allowed?
      Ability.allowed?(current_user, :create_release, project)
    end

    def create_tag
      Tags::CreateService
        .new(project, current_user)
        .execute(tag_name, ref, nil)
    end

    def create_release(tag)
      create_params = {
        author: current_user,
        name: tag.name,
        sha: tag.dereferenced_target.sha
      }.merge(params)

      release = project.releases.create!(create_params)

      success(tag: tag, release: release)
    rescue ActiveRecord::RecordInvalid
      error('Failed to save release record due to invalid parameters', 400)
    end
  end
end
