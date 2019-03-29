# frozen_string_literal: true

module MergeRequests
  class PushOptionsHandlerService
    attr_reader :results

    Result = Struct.new(:merge_request, :action, :success)
    Error = Class.new(StandardError)

    LIMIT = 10

    def initialize(project, user, changes, push_options)
      @project = project
      @user = user
      @push_options = push_options

      raise Error, 'User is required' if @user.blank?

      unless @push_options.values_at(:create, :target).compact.present?
        raise Error, 'Push options are not valid'
      end

      unless @project.merge_requests_enabled?
        raise Error, 'Merge requests are not enabled for project'
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
      @results = Set.new
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
      branches_and_changes = Gitlab::ChangesList.new(raw_changes).map do |change|
        next unless Gitlab::Git.branch_ref?(change[:ref])

        # Deleted branch
        next if Gitlab::Git.blank_ref?(change[:newrev])

        # Default branch
        branch_name = Gitlab::Git.branch_name(change[:ref])
        next if branch_name == @project.default_branch

        # For new branches, set the oldrev to the head of the default branch
        if Gitlab::Git.blank_ref?(change[:oldrev])
          change[:oldrev] = @project.default_branch
        end

        [branch_name, change]
      end.compact

      Hash[branches_and_changes]
    end

    def execute_for_branch(branch)
      merge_request = @merge_requests.find { |mr| mr.source_branch == branch }

      if merge_request.blank?
        create!(branch)
      else
        update!(merge_request)
      end
    end

    def create!(branch)
      merge_request = ::MergeRequests::CreateService.new(
        @project,
        @user,
        create_params(branch)
      ).execute

      @results << Result.new(
        merge_request,
        :create,
        merge_request.persisted?
      )
    end

    def update!(merge_request)
      return unless @push_options[:target]
      return if @target == merge_request.target_branch

      merge_request = ::MergeRequests::UpdateService.new(
        @project,
        @user,
        { target_branch: @target }
      ).execute(merge_request)

      @results << Result.new(
        merge_request,
        :update,
        merge_request.valid?
      )
    end

    def create_params(branch)
      change = @changes_by_branch[branch]

      commits = @project.repository.commits_between(change[:oldrev], change[:newrev])
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
  end
end
