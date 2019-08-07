# frozen_string_literal: true

require_relative '../../graphql_helpers'

module RuboCop
  module Cop
    module Graphql
      class FieldDescriptions < RuboCop::Cop::Cop
        include GraphqlHelpers

        MSG = 'Please add a `description` property to the field.'

        # ability_field and permission_field set a default description.
        def_node_matcher :field_arguments, <<~PATTERN
          (send nil? :field $...)
        PATTERN

        def_node_matcher :has_description?, <<~PATTERN
          (hash <(pair (sym :description) _) ...>)
        PATTERN

        def on_send(node)
          return unless in_type?(node)

          arguments = field_arguments(node)

          return unless arguments

          add_offense(node, location: :expression) unless has_description?(arguments.last)
        end
      end
    end
  end
end
