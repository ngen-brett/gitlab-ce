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

        result = Tags::CreateService
          .new(project, current_user)
          .execute(tag_name, ref, nil)

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

    def create_release(tag)
      release = project.releases.create!(
        name: name,
        description: description,
        author: current_user,
        tag: tag.name,
        sha: tag.dereferenced_target.sha
      )

      success(tag: tag, release: release)
    rescue ActiveRecord::RecordInvalid
      error('Failed to save release entry due to invalid parameters', 400)
    end
  end
end
