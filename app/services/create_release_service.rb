# frozen_string_literal: true

class CreateReleaseService < BaseService
  # rubocop: disable CodeReuse/ActiveRecord
  def execute(tag_name, release_description, name = nil, ref = nil)
    repository = project.repository
    existing_tag = repository.find_tag(tag_name)

    # we create a tag if ref was provided,
    # we make sure not to pass release_description or it will loop
    if existing_tag.blank? && ref.present?
      result = Tags::CreateService.new(project, current_user)
                 .execute(tag_name, ref, "")

      if result[:status] == :success
        project.repository.expire_tags_cache
        existing_tag = result[:tag]
      else
        return result
      end
    end

    if existing_tag
      release = project.releases.find_by(tag: tag_name)

      if release
        error('Release already exists', 409)
      else
        release = project.releases.create!(
          tag: tag_name,
          name: name || tag_name,
          sha: existing_tag.dereferenced_target.sha,
          author: current_user,
          description: release_description
        )

        success(release)
      end
    else
      error('Tag does not exist', 404)
    end
  end
  # rubocop: enable CodeReuse/ActiveRecord

  def success(release)
    super().merge(release: release)
  end
end
