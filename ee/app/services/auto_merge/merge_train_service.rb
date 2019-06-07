# frozen_string_literal: true

module AutoMerge
  class MergeTrainService < AutoMerge::BaseService
    include ::Gitlab::ExclusiveLeaseHelpers

    ProcessError = Class.new(StandardError)
    StalePipelineError = Class.new(StandardError)

    # enqueue to the merge train
    def execute(merge_request)
      unless merge_request.merge_train
        merge_request.build_merge_train(
          user: current_user,
          target_project: merge_request.target_project,
          target_branch: merge_request.target_branch)
      end

      super do
        if merge_request.saved_change_to_auto_merge_enabled?
          SystemNoteService.merge_train(merge_request, project, current_user, merge_request.merge_train)
        end

        refresh_train(merge_request)
      end
    end

    # process is validation of merge request status as part of train
    def process(merge_request)
      refresh_train(merge_request)
    end

    # cancel of merge train, and refresh of merge train
    def cancel(merge_request, reason: nil)
      super(merge_request) do
        SystemNoteService.cancel_merge_train(merge_request, project, current_user,
          reason: reason)

        merge_request.merge_train.destroy!

        refresh_train(merge_request)
      end
    end

    def available_for?(merge_request)
      return false unless merge_request.project.merge_trains_enabled?
      return false if merge_request.for_fork?
      return false unless merge_request.actual_head_pipeline&.complete?
      return false unless merge_request.mergeable?(skip_ci_check: true)

      true
    end

    private

    def refresh_train(merge_request)
      ProcessMergeTrainsWorker.perform_async(
        merge_request.target_project_id, merge_request.target_branch)
    end
  end
end
