# frozen_string_literal: true

class AddIndexesToCiBuildsAndPipelines < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    indexes.each do |index|
      add_concurrent_index *index
    end
  end

  def down
    indexes.each do |index|
      remove_concurrent_index *index
    end
  end

  private

  def indexes
    [
      [
        :ci_pipelines,
        [:project_id, :ref, :id],
        {
          order: { id: :desc },
          name: 'index_ci_pipelines_on_project_idandrefandiddesc'
        }
      ],
      [
        :ci_builds,
        [:commit_id, :artifacts_expire_at, :id],
        {
          where: "type = 'Ci::Build' AND (retried = false OR retried IS NULL) AND name IN ('sast', 'dependency_scanning', 'sast:container', 'container_scanning', 'dast')",
          name: 'index_ci_builds_on_commit_id_and_artifacts_expireatandidpartial'
        }
      ]
    ]
  end
end
