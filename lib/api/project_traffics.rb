# frozen_string_literal: true

module API
  class ProjectTraffics < Grape::API

    before do
      authenticate!
      authorize! :push_code, user_project
    end

    params do
      requires :id, type: String, desc: 'The ID of a project'
    end
    resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      desc 'Get the list of project fetch statistics for the last 30 days'
      get ":id/traffic/fetches" do
        oldest_active_staticstics_day = 30.days.ago
        fetch_stats = ProjectFetchStatistic.where(project: user_project).
          where('date > ?', oldest_active_staticstics_day).order(date: :desc)

        present :count, fetch_stats.sum(:count)
        present :fetches, fetch_stats, with: Entities::ProjectFetchStatistic
      end
    end
  end
end
