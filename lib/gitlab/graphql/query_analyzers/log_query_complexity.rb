# frozen_string_literal: true

module Gitlab
  module Graphql
    module QueryAnalyzers
      class LogQueryComplexity
        class << self
          def analyzer
            GraphQL::Analysis::QueryComplexity.new do |query, complexity|
              Rails.logger.info("[GraphQL Query Complexity] #{complexity}  | admin? #{query.context[:current_user]&.admin?}")
            end
          end
        end
      end
    end
  end
end
