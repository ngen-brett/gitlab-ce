require_relative '../../migration_helpers'

module RuboCop
  module Cop
    module Migration
      # Cop that enforces length constraints to string columns
      class AddLimitToStringColumns < RuboCop::Cop::Cop
        include MigrationHelpers

        MSG = 'String columns should have a limit constraint. 255 is suggested'.freeze

        def on_def(node)
          return unless in_migration?(node)

          node.each_descendant(:send) do |send_node|
            add_offense(send_node, location: :selector) if no_limit_on_string_column?(send_node)
          end
        end

        def on_send(node)
          return unless in_migration?(node)

          add_offense(node, location: :selector) if add_string_column_with_no_limit?(node)
        end

        private

        def no_limit_on_string_column?(node)
          node.children[1] == :string &&
            limit_not_present?(node.children)
        end

        def add_string_column_with_no_limit?(node)
          node.children[1] == :add_column &&
            node.children[4].value == :string &&
            limit_not_present?(node)
        end

        def limit_not_present?(node)
          (node.to_s =~ /:limit/).nil?
        end
      end
    end
  end
end
