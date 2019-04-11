# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Policy
        class ProtectedBranches < Policy::Specification
          def initialize(refs)
            @branches = Array(refs)
          end

          def satisfied_by?(pipeline, seed = nil)
            @branches.any? do |branch|
              matches_branch?(branch, pipeline) &&
                protected_branch?(branch, pipeline)
            end
          end

          private

          def matches_branch?(branch, pipeline)
            if regexp = Gitlab::UntrustedRegexp::RubySyntax.fabricate(branch, fallback: true)
              regexp.match?(pipeline.ref)
            else
              branch == pipeline.ref
            end
          end

          def protected_branch?(branch, pipeline)
            pipeline.project.protected_for?(branch)
          end
        end
      end
    end
  end
end
