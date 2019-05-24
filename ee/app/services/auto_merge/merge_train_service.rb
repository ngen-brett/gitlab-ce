# frozen_string_literal: true

module AutoMerge
  class MergeTrainService < AutoMerge::BaseService
    include ::Gitlab::ExclusiveLeaseHelpers

    ProcessError = Class.new(StandardError)
    StalePipelineError = Class.new(StandardError)

    def execute(merge_request)
      merge_request.build_merge_train(user: current_user) unless merge_request.merge_train

      super do
        if merge_request.saved_change_to_auto_merge_enabled?
          SystemNoteService.merge_train(merge_request, project, current_user, merge_request.merge_train)
        end
      end
    end

    def process(merge_request)
      in_lock("merge_train:#{merge_request.target_project_id}-#{merge_request.target_branch}") do
        unsafe_process(merge_request)
      end
    end

    def cancel(merge_request, reason: nil)
      super(merge_request) do
        SystemNoteService.cancel_merge_train(merge_request, project, current_user, reason: reason)
        merge_request.merge_train.destroy!
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

    def unsafe_process(merge_request)
      MergeTrain.all_in_train(merge_request).each do |merge_request|
        process_train(merge_request.merge_train)
      end
    end

    def process_train(merge_train)
      ensure_pipeline!(merge_train)
      validate!(merge_train)
      merge!(merge_train) if should_merge?(merge_train)
    rescue ProcessError => e
      cancel(merge_train.merge_request, reason: e.message)
    rescue StalePipelineError
      reset_pipeline(merge_train)
    end

    def ensure_pipeline!(merge_train)
      # NOTE: We will remove this line for running pipelines in parallel in the next iteration.
      return unless merge_train.first_in_train?
      return if merge_train.pipeline_id.present?

      pipeline = MergeRequests::CreatePipelineService
        .new(project, current_user, allow_duplicate: true).execute(merge_train.merge_request)

      unless pipeline&.latest_merge_request_pipeline?
        raise ProcessError, 'failed to create the latest pipeline for merged results'
      end

      merge_train.update!(pipeline: pipeline)
    end

    def validate!(merge_train)
      unless merge_train.project.merge_trains_enabled?
        raise ProcessError, 'project disabled merge trains'
      end

      unless merge_train.merge_request.mergeable?(skip_ci_check: true)
        raise ProcessError, 'merge request is not mergeable'
      end

      if merge_train.pipeline
        if merge_train.pipeline.complete? && !merge_train.pipeline.success?
          raise ProcessError, 'pipeline did not succeed'
        end

        unless merge_train.pipeline.latest_merge_request_pipeline?
          raise StalePipelineError, 'pipeline for merged results is stale'
        end
      end
    end

    def merge!(merge_train)
      merge_request = merge_train.merge_request

      MergeRequests::MergeService.new(project, current_user, merge_request.merge_params)
                                 .execute(merge_request)

      raise ProcessError, 'failed to merge' unless merge_request.merged?

      merge_train.destroy!
    end

    def should_merge?(merge_train)
      merge_train.pipeline&.success? && merge_train.first_in_train?
    end

    def reset_pipeline(merge_train)
      merge_train.pipeline_id = nil
      ensure_pipeline!(merge_train)
    rescue ProcessError => e
      cancel(merge_train.merge_request, reason: e.message)
    end
  end
end
