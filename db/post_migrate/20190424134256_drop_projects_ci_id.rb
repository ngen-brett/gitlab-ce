# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class DropProjectsCiId < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  def up
    if index_exists?(:projects, :ci_id)
      remove_index :projects, :ci_id
    end

    if column_exists?(:projects, :ci_id)
      remove_column :projects, :ci_id
    end
  end

  def down
    add_column :projects, :ci_id, :integer
    add_index :projects, :ci_id
  end
end
