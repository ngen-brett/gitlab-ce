# frozen_string_literal: true

module Gitlab
  module Graphql
    module QueryAnalyzers
      class LoggerAnalyzer
        def initialize
          @info_hash = {}
          @time_started = nil
        end

        # Called before initializing the analyzer.
        # Returns true to run this analyzer, or false to skip it.
        def analyze?(query)
          true # unless there's some reason why we wouldn't log?
        end

        # Called before the visit.
        # Returns the initial value for `memo`
        def initial_value(query)
          @time_started = Time.zone.now
          @info_hash[:query_string] = query.query_string
          @info_hash[:variables] = query.provided_variables
          @info_hash[:complexity] = complexity
          @info_hash[:depth] = depth
        end

        # This is like the `reduce` callback.
        # The return value is passed to the next call as `memo`
        def call(memo, visit_type, irep_node)
        end

        # Called when we're done the whole visit.
        # The return value may be a GraphQL::AnalysisError (or an array of them).
        # Or, you can use this hook to write to a log, etc
        def final_value(memo)
          @info_hash[:duration] = "#{duration.round(1)}ms"
          GraphqlLogger.info(@info_hash)
        end

        private

        def complexity
          GraphQL::Analysis::QueryComplexity.new do |query, complexity_value|
            @complexity = complexity_value
          end
          @complexity
        end

        def depth
          GraphQL::Analysis::QueryDepth.new do |query, depth_value|
            @depth = depth_value
          end
          @depth
        end

        def duration
          nanoseconds = Time.zone.now - @time_started
          nanoseconds / 1.million
        end
      end
    end
  end
end
