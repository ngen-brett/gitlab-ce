# frozen_string_literal: true

class AddGroupEmailsEnabled < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  disable_ddl_transaction!

  def change
    add_column_with_default :namespaces, :emails_enabled, :boolean, default: true, allow_null: false
  end
end
