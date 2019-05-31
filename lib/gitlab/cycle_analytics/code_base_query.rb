# frozen_string_literal: true

module Gitlab
  module CycleAnalytics
    module CodeBaseQuery
      def stage_query(project_ids)
        super(project_ids).where(issue_metrics_table[:first_mentioned_in_commit_at].not_eq(nil))
      end
    end
  end
end
