# frozen_string_literal: true

module Gitlab
  module DeploymentPlatform
    class WithNestedGroups
      attr_reader :project

      def initialize(project)
        @project = project
      end

      def calculate
        cte = recursive_cte
        cte_alias = cte.table.alias(Clusters::Cluster.table_name)

        Clusters::Cluster
          .unscoped
          .with
          .recursive(cte.to_arel)
          .from(cte_alias)
      end

      private

      def base_group_id
        project.namespace_id
      end

      def recursive_cte
        cte = Gitlab::SQL::RecursiveCTE.new(:clusters_cte)

        clusters = Clusters::Cluster.arel_table
        groups = Group.arel_table

        clusters_star = table_star(clusters)
        group_parent_id_alias = alias_as_column(groups[:parent_id], 'group_parent_id')

        base = Clusters::Cluster
          .unscoped
          .select([clusters_star, group_parent_id_alias])
          .joins(:groups)
          .where(groups[:id].eq(base_group_id))
        cte << base

        parent_query = Clusters::Cluster
          .unscoped
          .select([clusters_star, group_parent_id_alias])
          .from([cte.table, clusters])
          .joins(:groups)
          .where(groups[:id].eq(cte.table[:group_parent_id]))
        cte << parent_query

        cte
      end

      def table_star(table)
        table[Arel.star]
      end

      def alias_as_column(value, alias_to)
        Arel::Nodes::As.new(value, Arel::Nodes::SqlLiteral.new(alias_to))
      end
    end
  end
end
