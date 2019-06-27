# frozen_string_literal: true

module Gitlab
  module Diff
    module PositionTracer
      class Base
        attr_accessor :project
        attr_accessor :old_diff_refs
        attr_accessor :new_diff_refs
        attr_accessor :paths

        def initialize(project:, old_diff_refs:, new_diff_refs:, paths: nil)
          @project = project
          @old_diff_refs = old_diff_refs
          @new_diff_refs = new_diff_refs
          @paths = paths
        end

        def trace(position)
          return unless old_diff_refs&.complete? && new_diff_refs&.complete?
          return unless position.diff_refs == old_diff_refs

          trace_changes(position)
        end

        def trace_changes(position)
          raise NotImplementedError
        end

        private

        def ac_diffs
          @ac_diffs ||= compare(
            old_diff_refs.base_sha || old_diff_refs.start_sha,
            new_diff_refs.base_sha || new_diff_refs.start_sha,
            straight: true
          )
        end

        def bd_diffs
          @bd_diffs ||= compare(old_diff_refs.head_sha, new_diff_refs.head_sha, straight: true)
        end

        def cd_diffs
          @cd_diffs ||= compare(new_diff_refs.start_sha, new_diff_refs.head_sha)
        end

        def compare(start_sha, head_sha, straight: false)
          compare = CompareService.new(project, head_sha).execute(project, start_sha, straight: straight)
          compare.diffs(paths: paths, expanded: true)
        end
      end
    end
  end
end
