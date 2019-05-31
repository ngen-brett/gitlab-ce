# frozen_string_literal: true

class CreateNamespaceStorageStatistics < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :namespace_storage_statistics do |t|
      t.references :namespace,
        foreign_key: { on_delete: :cascade },
        index: true,
        null: false

      t.bigint :repository_size, null: false, default: 0
      t.bigint :lfs_objects_size, null: false, default: 0
      t.bigint :wiki_size, null: false, default: 0
      t.bigint :build_artifacts_size, null: false, default: 0
      t.bigint :storage_size, null: false, default: 0
      t.bigint :packages_size, null: false, default: 0

      t.timestamps_with_timezone null: false
    end
  end
end
