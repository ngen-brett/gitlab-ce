# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddIndexToAuditEventsCreatedAt < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :audit_events, [:created_at, :id]
  end

  def down
    remove_concurrent_index :audit_events, [:created_at, :id]
  end
end
