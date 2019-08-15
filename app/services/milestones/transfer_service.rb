# frozen_string_literal: true

module Milestones
  class TransferService
    attr_reader :current_user, :old_group, :project

    def initialize(current_user, old_group, project)
      @current_user = current_user
      @old_group = old_group
      @project = project
    end

    def execute
      return unless old_group.present?

      Milestone.transaction do
        milestones_to_transfer.find_each do |milestone|
          new_milestone_id = create_milestone!(milestone)

          update_issues_milestone(milestone.id, new_milestone_id)
          update_merge_requests_milestone(milestone.id, new_milestone_id)
        end
      end
    end

    private

    # rubocop: disable CodeReuse/ActiveRecord
    def milestones_to_transfer
      Milestone.from_union([
          group_milestones_applied_to_issues,
          group_milestones_applied_to_merge_requests
        ])
        .reorder(nil)
        .distinct
    end
    # rubocop: enable CodeReuse/ActiveRecord

    # rubocop: disable CodeReuse/ActiveRecord
    def group_milestones_applied_to_issues
      Milestone.joins(:issues)
        .where(
          issues: { project_id: project.id },
          group_id: old_group.id
        )
    end
    # rubocop: enable CodeReuse/ActiveRecord

    # rubocop: disable CodeReuse/ActiveRecord
    def group_milestones_applied_to_merge_requests
      Milestone.joins(:merge_requests)
        .where(
          merge_requests: { target_project_id: project.id },
          group_id: old_group.id
        )
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def create_milestone!(milestone)
      params = milestone.attributes.slice('title', 'description', 'start_date', 'due_date')

      new_milestone = CreateService.new(project, current_user, params).execute

      new_milestone.id
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def update_issues_milestone(old_milestone_id, new_milestone_id)
      Issue.where(project: project, milestone_id: old_milestone_id)
        .update_all(milestone_id: new_milestone_id)
    end
    # rubocop: enable CodeReuse/ActiveRecord

    # rubocop: disable CodeReuse/ActiveRecord
    def update_merge_requests_milestone(old_milestone_id, new_milestone_id)
      MergeRequest.where(project: project, milestone_id: old_milestone_id)
        .update_all(milestone_id: new_milestone_id)
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
