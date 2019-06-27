# frozen_string_literal: true

# Finds the diff position in the new diff that corresponds to the same location
# specified by the provided position in the old diff.
module Gitlab
  module Diff
    module PositionTracer
      def self.for(type, **args)
        if type == 'text'
          LinePositionTracer.new(args)
        end
      end
    end
  end
end
