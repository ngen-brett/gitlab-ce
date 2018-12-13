# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CreateProjectFetchStatistics < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :project_fetch_statistics do |t|
      t.references :project, index: true, foreign_key: { on_delete: :cascade }
      t.integer :count
      t.date :date
    end

    add_index :project_fetch_statistics, [:project_id, :date], unique: true
  end
end
