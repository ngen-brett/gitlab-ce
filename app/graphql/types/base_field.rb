# frozen_string_literal: true

module Types
  class BaseField < GraphQL::Schema::Field
    prepend Gitlab::Graphql::Authorize

    DEFAULT_COMPLEXITY = 1

    def initialize(*args, **kwargs, &block)
      @calls_gitaly = !!kwargs.delete(:calls_gitaly)
      kwargs[:complexity] ||= field_complexity(kwargs[:resolver_class])

      super(*args, **kwargs, &block)
    end

    private

    def field_complexity(resolver_class)
      if resolver_class
        field_resolver_complexity
      else
        DEFAULT_COMPLEXITY
      end
    end

    def field_resolver_complexity
      # Complexity can be either integer or proc. If proc is used then it's
      # called when computing a query complexity and context and query
      # arguments are available for computing complexity.  For resolvers we use
      # proc because we set complexity depending on arguments and number of
      # items which can be loaded.
      proc do |ctx, args, child_complexity|
        page_size = @max_page_size || ctx.schema.default_max_page_size
        limit_value = [args[:first], args[:last], page_size].compact.min

        # Resolvers may add extra complexity depending on used arguments
        complexity = child_complexity + self.resolver&.try(:resolver_complexity, args).to_i

        # Resolvers may add extra complexity depending on number of items being loaded.
        multiplier = self.resolver&.try(:complexity_multiplier, args).to_f
        complexity += complexity * limit_value * multiplier
        complexity +=1 if @calls_gitaly

        complexity.to_i
      end
    end

    def calls_gitaly_check
      # Will inform you if :calls_gitaly should be true or false based on the number of Gitaly calls
      # involved with the request.
      return if @calls_gitaly == Gitlab::GitalyClient.get_request_count > 0

      raise "Gitaly is called for #{field.name} - please add `calls_gitaly: true` to the field declaration"
      rescue => e
        Gitlab::Sentry.track_exception(e)
    end
  end
end
