
# frozen_string_literal: true

class CreatePackagesConanFileMetadata < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :packages_conan_file_metadata do |t|
      t.references :package_file, index: true, null: false, foreign_key: { to_table: :packages_package_files, on_delete: :cascade }, type: :integer
      t.string "recipe", null: false
      t.string "path", null: false
      t.string "revision", null: false, default: "0"
      t.index %w[package_file_id recipe], name: "index_conan_file_metadata_on_package_file_id_and_recipe", using: :btree

      t.timestamps_with_timezone
    end
  end
end
