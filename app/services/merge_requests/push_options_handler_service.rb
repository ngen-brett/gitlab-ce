# frozen_string_literal: true

module MergeRequests
  class PushOptionsHandlerService
    Error = Class.new(StandardError)

    LIMIT = 10

    attr_reader :errors

    def initialize(project, user, changes, push_options)
      @project = project
      @user = user
      @push_options = push_options

      raise Error, 'User is required' if @user.blank?

      unless @project.merge_requests_enabled?
        raise Error, 'Merge requests are not enabled for project'
      end

      unless @push_options.values_at(:create, :target).compact.present?
        raise Error, 'Push options are not valid'
      end

      @changes_by_branch = parse_changes(changes)
      @branches = @changes_by_branch.keys

      if @branches.size > LIMIT
        raise Error, "Too many branches pushed (#{@branches.size} were pushed, limit is #{LIMIT})"
      end

      @target = @push_options[:target] || @project.default_branch
      @merge_requests = MergeRequest.from_project(@project)
                                    .opened
                                    .from_source_branches(@branches)
                                    .to_a # fetch now
      @errors = []
    end

    def execute
      @branches.each do |branch|
        execute_for_branch(branch)
      end

      self
    end

    private

    # Parses changes in the push.
    # Returns a hash of branch => changes_list
    def parse_changes(raw_changes)
      Gitlab::ChangesList.new(raw_changes).each_with_object({}) do |change, changes|
        next unless Gitlab::Git.branch_ref?(change[:ref])

        # Deleted branch
        next if Gitlab::Git.blank_ref?(change[:newrev])

        # Default branch
        branch_name = Gitlab::Git.branch_name(change[:ref])
        next if branch_name == @project.default_branch

        changes[branch_name] = change
      end
    end

    def execute_for_branch(branch)
      merge_request = @merge_requests.find { |mr| mr.source_branch == branch }

      if merge_request
        update!(merge_request)
      else
        create!(branch)
      end
    end

    def create!(branch)
      unless @push_options[:create]
        @errors << "A merge_request.create push option is required to create a merge request for branch #{branch}"
        return
      end

      merge_request = ::MergeRequests::CreateService.new(
        @project,
        @user,
        create_params(branch)
      ).execute

      collect_errors_from_merge_request(merge_request) unless merge_request.persisted?
    end

    def update!(merge_request)
      return if @target == merge_request.target_branch

      merge_request = ::MergeRequests::UpdateService.new(
        @project,
        @user,
        { target_branch: @target }
      ).execute(merge_request)

      collect_errors_from_merge_request(merge_request) unless merge_request.valid?
    end

    def create_params(branch)
      change = @changes_by_branch.fetch(branch)

      commits = @project.repository.commits_between(@project.default_branch, change[:newrev])
      commits = CommitCollection.new(@project, commits)
      commit = commits.without_merge_commits.first

      {
        assignee: @user,
        source_branch: branch,
        target_branch: @target,
        title: commit&.title&.strip || 'New Merge Request',
        description: commit&.description&.strip
      }
    end

    def collect_errors_from_merge_request(merge_request)
      @errors << merge_request.errors.full_messages.to_sentence
    end
  end
end
