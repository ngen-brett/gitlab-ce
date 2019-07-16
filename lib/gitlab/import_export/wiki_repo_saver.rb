# frozen_string_literal: true

module Gitlab
  module ImportExport
    class WikiRepoSaver < RepoSaver
      def save
        wiki = ProjectWiki.new(project)
        @repository = wiki.repository
        return true unless wiki_repository_exists? # it's okay to have no Wiki

        bundle_to_disk
      end

      private

      def bundle_full_path
        File.join(shared.export_path, ImportExport.wiki_repo_bundle_filename)
      end

      def wiki_repository_exists?
        repository.exists? && !repository.empty?
      end
    end
  end
end
