# frozen_string_literal: true

class ProjectPagesMetadatum < ApplicationRecord
  MINIMUM_SCHEMA_VERSION = 20190909045845

  self.primary_key = :project_id

  belongs_to :project, inverse_of: :project_pages_metadatum

  scope :project_scoped, -> { where('projects.id=project_pages_metadata.project_id') }
  scope :deployed, -> { where(deployed: true) }

  def self.available?
    return true unless Rails.env.test?

    Gitlab::SafeRequestStore.fetch(:project_pages_metadatum_available_flag) do
      ActiveRecord::Migrator.current_version >= MINIMUM_SCHEMA_VERSION
    end
  end

  # Flushes cached information about schema
  def self.reset_column_information
    Gitlab::SafeRequestStore[:project_pages_metadatum_available_flag] = nil
    super
  end
end
