# frozen_string_literal: true

module MergeRequests
  class SquashService < MergeRequests::WorkingCopyBaseService
    attr_reader :message

    def initialize(project, merge_request, user = nil, params = {})
      @merge_request = merge_request

      @message = params.delete(:squash_commit_message).presence ||
        merge_request.default_squash_commit_message

      @repository = target_project.repository

      super(project, user, params)
    end

    def execute
      squash || error('Failed to squash. Should be done manually.')
    end

    def squash
      # If performing a squash would result in no change, then
      # immediately return a success message without performing a squash
      if merge_request.commits_count < 2 && message == merge_request.default_squash_commit_message
        return success(squash_sha: merge_request.diff_head_sha)
      end

      if merge_request.squash_in_progress?
        return error('Squash task canceled: another squash is already in progress.')
      end

      squash_sha = repository.squash(current_user, merge_request, message)

      success(squash_sha: squash_sha)
    rescue => e
      log_error("Failed to squash merge request #{merge_request.to_reference(full: true)}:")
      log_error(e.message)
      false
    end
  end
end
