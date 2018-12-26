# frozen_string_literal: true

module Releases
  class UpdateService < BaseService
    include Releases::Concerns

    def execute
      return error('Tag does not exist', 404) unless existing_tag
      return error('Release does not exist', 404) unless release
      return error('Access Denied', 403) unless allowed?

      if release.update(params)
        success(release: release)
      else
        error(release.errors.messages || '400 Bad request', 400)
      end
    end

    private

    def allowed?
      Ability.allowed?(current_user, :update_release, release)
    end
  end
end
