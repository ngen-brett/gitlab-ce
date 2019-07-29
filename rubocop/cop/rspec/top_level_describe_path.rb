# frozen_string_literal: true

require 'rubocop/rspec/top_level_describe'

module RuboCop
  module Cop
    module RSpec
      class TopLevelDescribePath < RuboCop::Cop::Cop
        include RuboCop::RSpec::TopLevelDescribe

        MESSAGE = 'A file with a top-level `describe` must end in _spec.rb.'

        def on_top_level_describe(node, args)
          return if File.fnmatch?('*_spec.rb', processed_source.buffer.name)
          return if File.fnmatch?('*/frontend/fixtures/*', processed_source.buffer.name)
          return if shared_example?(node)

          add_offense(node, message: MESSAGE)
        end

        private

        def shared_example?(node)
          node.ancestors.any? do |node|
            node.respond_to?(:method_name) && node.method_name == :shared_examples
          end
        end
      end
    end
  end
end
