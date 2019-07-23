# frozen_string_literal: true

module Banzai
  module Filter
    # HTML filter that replaces commit references with links.
    #
    # This filter supports cross-project references.
    class CommitReferenceFilter < AbstractReferenceFilter
      self.reference_type = :commit

      def self.object_class
        Commit
      end

      def references_in(*args, &block)
        text, pattern = args

        matches = extract_valid_commit_references(text, pattern)

        text.gsub(pattern) do |match|
          if matches[match]
            yield(
              match,
              matches[match][:commit],
              matches[match][:project],
              matches[match][:namespace],
              matches[match][:matches],
              matches[match][:commit_object]
            )
          else
            yield match, $~[:commit], $~[:project], $~[:namespace], $~
          end
        end
      end

      def extract_valid_commit_references(text, pattern = Commit.reference_pattern)
        return {} unless parent&.repository

        matches = {}

        # FIXME: we don't want gsub here, we want to iterate over each match but
        #   I'm tired right now and can't remember the method I actually want.
        #
        text.gsub(pattern) do |match|
          matches[match] = {
            commit:    $~[:commit],
            project:   $~[:project],
            namespace: $~[:namespace],
            matches:   $~
          }
        end

        # Select the matches that are local to the current parent
        #
        # OPTIMIZE: Just collect the commit_ids into an array
        local_matches = matches.select { |k, v| v[:project].nil? && v[:namespace].nil? }

        # Lookup the objects for local commit references
        #
        commit_objects = Gitlab::Git::Commit.batch_by_oid(parent&.repository, local_matches.keys)

        commit_objects.each do |commit_object|
          if matches[commit_object.id]
            matches[commit_object.id][:commit_object] = ::Commit.new(commit_object, project)
          end
        end

        matches
      end

      def self.references_in(text, pattern = Commit.reference_pattern)
        text.gsub(pattern) do |match|
          yield match, $~[:commit], $~[:project], $~[:namespace], $~
        end
      end

      def find_object(project, id)
        return unless project.is_a?(Project)

        if project && project.valid_repo?
          # n+1: https://gitlab.com/gitlab-org/gitlab-ce/issues/43894
          Gitlab::GitalyClient.allow_n_plus_1_calls { project.commit(id) }
        end
      end

      def referenced_merge_request_commit_shas
        return [] unless noteable.is_a?(MergeRequest)

        @referenced_merge_request_commit_shas ||= begin
          referenced_shas = references_per_parent.values.reduce(:|).to_a
          noteable.all_commit_shas.select do |sha|
            referenced_shas.any? { |ref| Gitlab::Git.shas_eql?(sha, ref) }
          end
        end
      end

      def url_for_object(commit, project)
        h = Gitlab::Routing.url_helpers

        if referenced_merge_request_commit_shas.include?(commit.id)
          h.diffs_project_merge_request_url(project,
                                            noteable,
                                            commit_id: commit.id,
                                            only_path: only_path?)
        else
          h.project_commit_url(project,
                               commit,
                               only_path: only_path?)
        end
      end

      def object_link_text_extras(object, matches)
        extras = super

        path = matches[:path] if matches.names.include?("path")
        if path == '/builds'
          extras.unshift "builds"
        end

        extras
      end

      private

      def noteable
        context[:noteable]
      end

      def only_path?
        context[:only_path]
      end
    end
  end
end
