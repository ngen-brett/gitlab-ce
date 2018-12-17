# frozen_string_literal: true

class ReleasesFinder
  def initialize(project, current_user = nil)
    @project = project
    @current_user = current_user
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def execute
    return [] unless Ability.allowed?(@current_user, :download_code, @project)

    @project.releases.order('created_at DESC')
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
