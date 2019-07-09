# frozen_string_literal: true

module Gitlab
  module CycleAnalytics
    module BaseQuery
      include MetricsTables
      include Gitlab::Database::Median
      include Gitlab::Database::DateTime

      private

      def base_query
        @base_query ||= stage_query(projects.map(&:id))
      end

      def stage_query(project_ids)
        query = mr_closing_issues_table.join(issue_table).on(issue_table[:id].eq(mr_closing_issues_table[:issue_id]))
          .join(issue_metrics_table).on(issue_table[:id].eq(issue_metrics_table[:issue_id]))
          .join(projects_table).on(issue_table[:project_id].eq(projects_table[:id]))
          .join(routes_table).on(projects_table[:namespace_id].eq(routes_table[:source_id]))
          .project(issue_table[:project_id].as("project_id"))
          .where(issue_table[:project_id].in(project_ids))
          .where(routes_table[:source_type].eq('Namespace'))
          .where(issue_table[:created_at].gteq(@options[:from])) # rubocop:disable Gitlab/ModuleWithInstanceVariables

        # Load merge_requests

        query = load_merge_requests(query)

        query
      end

      def load_merge_requests(query)
        query.join(mr_table, Arel::Nodes::OuterJoin)
          .on(mr_table[:id].eq(mr_closing_issues_table[:merge_request_id]))
          .join(mr_metrics_table)
          .on(mr_table[:id].eq(mr_metrics_table[:merge_request_id]))
      end
    end
  end
end
