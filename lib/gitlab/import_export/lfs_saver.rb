# frozen_string_literal: true

module Gitlab
  module ImportExport
    class LfsSaver
      include Gitlab::ImportExport::CommandLineUtil

      attr_accessor :lfs_json, :project, :shared

      def initialize(project:, shared:)
        @project = project
        @shared = shared
        @lfs_json = {}
      end

      def save
        project.all_lfs_objects.each do |lfs_object|
          save_lfs_object(lfs_object)
          append_lfs_json(lfs_object)
        end

        write_lfs_json

        true
      rescue => e
        shared.error(e)

        false
      end

      private

      def save_lfs_object(lfs_object)
        if lfs_object.local_store?
          copy_file_for_lfs_object(lfs_object)
        else
          download_file_for_lfs_object(lfs_object)
        end
      end

      def append_lfs_json(lfs_object)
        lfs_json[lfs_object.oid] =
          lfs_object.lfs_objects_projects.where(project: project).pluck('repository_type')
      end

      def download_file_for_lfs_object(lfs_object)
        destination = destination_path_for_object(lfs_object)
        mkdir_p(File.dirname(destination))

        File.open(destination, 'w') do |file|
          IO.copy_stream(URI.parse(lfs_object.file.url).open, file)
        end
      end

      def copy_file_for_lfs_object(lfs_object)
        copy_files(lfs_object.file.path, destination_path_for_object(lfs_object))
      end

      def write_lfs_json
        mkdir_p(shared.export_path)
        File.write(lfs_json_path, lfs_json.to_json)
      end

      def destination_path_for_object(lfs_object)
        File.join(lfs_export_path, lfs_object.oid)
      end

      def lfs_export_path
        File.join(shared.export_path, ImportExport.lfs_objects_storage)
      end

      def lfs_json_path
        File.join(shared.export_path, ImportExport.lfs_objects_filename)
      end
    end
  end
end
