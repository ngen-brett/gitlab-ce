# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    class MigrateLegacyUploads # rubocop:disable Metrics/ClassLength
      # For bulk_queue_background_migration_jobs_by_range
      include Database::MigrationHelpers

      class Upload < ActiveRecord::Base
        self.table_name = 'uploads'

        include ::EachBatch
      end

      class UploadMover
        attr_reader :upload, :project, :note

        def initialize(upload)
          @upload = upload
          @note = Note.find_by(id: upload.model_id)
          @project = Project.find_by(id: note.project_id)
        end

        def execute
          move_file
          update_upload
          update_note
        end

        private

        def move_file
          destination_dir = File.join(FileUploader.root, project.disk_path, secret)
          destination_file_path = File.join(destination_dir, file_name)

          unless File.exist?(source_file_path)
            puts "Source file `#{source_file_path}` doesn't exist. Skipping."
            return
          end

          puts "Moving file #{source_file_path} -> #{destination_file_path}"

          FileUtils.mkdir_p(destination_dir)
          FileUtils.move(source_file_path, destination_file_path)
        end

        def update_upload
          upload.update(
            secret: secret,
            path: File.join(secret, file_name),
            model_id: project.id,
            model_type: 'Project',
            uploader: 'FileUploader'
          )
        end

        def update_note
          note.update(
            attachment: nil,

          )
        end

        def source_file_path
          @source_file_path ||= File.join(base_directory, upload.path)
        end

        def file_name
          source_file_path.split('/').last
        end

        def secret
          @secret ||= SecureRandom.hex
        end

        def base_directory
          # File.join(Rails.root, 'public')

          FileUploader.options['storage_path']
        end
      end

      def perform
        Upload.where(uploader: 'AttachmentUploader').each_batch do |batch|
          batch.each { |upload| UploadMover.new(upload).execute }
        end
      end
    end
  end
end
