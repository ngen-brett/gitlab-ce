# frozen_string_literal: true

class ProjectInvitedGroupsMembersFinder
  attr_reader :project

  def initialize(project)
    @project = project
  end

  def execute
    invited_groups_ids_including_ancestors = Gitlab::ObjectHierarchy
      .new(project.invited_groups)
      .base_and_ancestors
      .select(:id)

    GroupMember.where(source_id: invited_groups_ids_including_ancestors)
      .non_request
  end
end
