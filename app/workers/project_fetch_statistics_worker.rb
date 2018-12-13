# frozen_string_literal: true

class ProjectFetchStatisticsWorker
  include ApplicationWorker
  include CronjobQueue

  def perform(project_id)
    Projects::FetchStatisticsService.new(Project.find(project_id)).execute
  end
end
