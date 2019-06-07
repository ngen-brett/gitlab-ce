module MergeTrain
  class ProcessMergeTrainService < ::BaseService
    include ::Gitlab::ExclusiveLeaseHelpers

    attr_reader :merge_train

    ValidationError = Class.new(StandardError)

    def initalize(merge_train)
      @merge_train = merge_train
    end

    def execute
      validate!
      drop_stale_pipeline
      ensure_pipeline
      merge! if pipeline.success? && merge_train.first_in_train?
      success
    rescue ValidationError => e
      error(e.message)
    end

    private

    def validate!
      unless project.merge_trains_enabled?
        raise ValidationError, "merge trains not enabled"
      end

      unless merge_request.mergeable?(skip_ci_check: true)
        raise ValidationError, "merge not mergeable"
      end

      unless merge_request.target_project == merge_train.target_project
        raise ValidationError, "invalid target project"
      end

      unless merge_request.target_branch == merge_train.target_branch
        raise ValidationError, "invalid target branch"
      end

      if pipeline&.latest_merge_request_pipeline? &&
          pipeline.complete? &&
          !pipeline.success?
        raise ValidationError, "pipeline did not succeed"
      end
    end

    def merge!
      MergeRequests::MergeService
        .new(merge_request.target_project, merge_train.user, merge_request.merge_params)
        .execute(merge_request)
    end

    def drop_stale_pipeline
      return unless merge_train&.pipeline&.latest_merge_request_pipeline?

      # TODO: should we execute cancel on `pipeline_id`

      merge_train.pipeline_id = nil
    end

    def ensure_pipeline!(merge_train)
      return unless merge_train.pipeline

      # TODO: this should create `refs/merge-request/train`
      # TODO: this should call directly
      #   Ci::CreatePipelineService.new(merge_request.source_project, current_user,
      #       ref: merge_request.ref_path)
      #     .execute(:merge_request_event, merge_request: merge_request)
  
      pipeline = MergeRequests::CreatePipelineService
        .new(target_project, merge_user, allow_duplicate: true)
        .execute(merge_request)

      # TODO: is that needed?
      unless pipeline&.latest_merge_request_pipeline?
        raise ValidationError, 'failed to create the latest pipeline for merged results'
      end

      merge_train.update!(pipeline: pipeline)
    end

    def error(reason, params = {})
      AutoMerge::MergeTrainService.new(target_project, merge_user)
        .cancel(merge_request, reason: reason)

      super
    end

    def merge_user
      merge_train.user
    end

    def merge_request
      merge_train.merge_request
    end

    def target_project
      merge_request.target_project
    end

    def pipeline
      merge_train.pipeline
    end
  end
end
