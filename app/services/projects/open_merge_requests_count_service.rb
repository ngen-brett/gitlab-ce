# frozen_string_literal: true

module Projects
  # Service class for counting and caching the number of open merge requests of
  # a project.
  class OpenMergeRequestsCountService < Projects::CountService
    def relation_for_count
      if @project.respond_to?(:merge_requests)
        @project.merge_requests.opened
      else
        self.class.query(@project)
      end
    end

    def cache_key_name
      'open_merge_requests_count'
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def self.query(projects)
      MergeRequest.opened.where(project: projects)
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
