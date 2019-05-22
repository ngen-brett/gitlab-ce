# frozen_string_literal: true

module Gitlab
  class AutoMergeStrategy
    class MergeWhenPipelineSucceeds << Base
      def execute(merge_request)
        return :failed unless merge_request.actual_head_pipeline

        if merge_request.actual_head_pipeline.active?
          merge_request.merge_params.merge!(params)

          # The service is also called when the merge params are updated.
          already_approved = merge_request.merge_when_pipeline_succeeds?

          unless already_approved
            merge_request.merge_when_pipeline_succeeds = true
            merge_request.merge_user = @current_user

            SystemNoteService.merge_when_pipeline_succeeds(merge_request, @project, @current_user, merge_request.diff_head_commit)
          end

          merge_request.save

          :merge_when_pipeline_succeeds
        elsif merge_request.actual_head_pipeline.success?
          # This can be triggered when a user clicks the auto merge button while
          # the tests finish at about the same time
          merge_request.merge_async(current_user.id, merge_params)

          :success
        else
          :failed
        end
      end

      def process
        return unless pipeline.success?

        pipeline_merge_requests(pipeline) do |merge_request|
          next unless merge_request.merge_when_pipeline_succeeds?
          next unless merge_request.mergeable?

          merge_request.merge_async(merge_request.merge_user_id, merge_request.merge_params)
        end
      end

      def cancellable?(merge_request)
        return false unless merge_when_pipeline_succeeds?

        merge_request.can_be_merged_by?(user) || merge_request.author == user
      end

      def cancel(merge_request)
        return cancellable?(merge_request)

        merge_request.merge_when_pipeline_succeeds = false
        merge_request.merge_user = nil

        if merge_params
          merge_params.delete('should_remove_source_branch')
          merge_params.delete('commit_message')
          merge_params.delete('squash_commit_message')
        end
    
        merge_request.save
      end
    end
  end
end