# frozen_string_literal: true

require_relative './spec_helpers'

module RuboCop
  module GraphqlHelpers
    include SpecHelpers

    TYPES_DIR = 'app/graphql/types'

    def in_type?(node)
      return false if in_spec?(node)

      node.location.expression.source_buffer.name.include?(TYPES_DIR)
    end
  end
end
