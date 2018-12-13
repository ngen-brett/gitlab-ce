# frozen_string_literal: true

module Projects
  class FetchStatisticsService
    attr_reader :project

    def initialize(project)
      @project = project
    end

    def execute
      increment_fetch_count_sql = <<~SQL
        INSERT INTO #{ProjectFetchStatistic.table_name} (project_id, date, count)
        VALUES (#{project.id}, '#{Date.today}', 1)
      SQL

      increment_fetch_count_sql = increment_fetch_count_sql + if Gitlab::Database.postgresql?
        'ON CONFLICT (project_id, date) DO UPDATE SET count = EXCLUDED.count + 1'
      else
        'ON DUPLICATE KEY UPDATE count = VALUES(count) + 1'
      end

      ActiveRecord::Base.connection.execute(increment_fetch_count_sql)
    end
  end
end

