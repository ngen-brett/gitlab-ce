# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # This background migration updates records on namespaces table according
    # to the given namespace IDs range. A _single_ update is issued for the given range.
    class PopulateNamespaceRootIdColumn
      def perform(from_id, to_id)
        root_namespaces = root_namespaces_between(from_id: from_id, to_id: to_id)

        namespaces_information = {}.tap do |namespaces_information|
          root_namespaces.each do |root_namespace|
            root_namespace.self_and_descendants.each do |namespace|
              namespaces_information[namespace.id] = root_namespace.id
            end
          end
        end

        update_sql = build_update_namespaces_root_sql(namespaces_information)

        execute(update_sql)
      end

      private

      def root_namespaces_between(from_id:, to_id:)
        Namespace
          .where('parent_id IS NULL')
          .where(id: from_id..to_id)
      end

      def execute(sql)
        connection.execute(sql)
      end

      def connection
        @connection ||= ActiveRecord::Base.connection
      end

      def build_update_namespaces_root_sql(namespaces_information)
        case_statement = []

        namespaces_information.each do |child_namespace_id, root_namespace_id|
          case_statement << "WHEN #{child_namespace_id} THEN #{root_namespace_id}"
        end

        <<~SQL
        UPDATE namespaces
          SET root_id = CASE id
          #{case_statement.join("\n")}
          END
        WHERE id IN (#{namespaces_information.keys.join(",")})
        SQL
      end
    end
  end
end
