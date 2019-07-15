# frozen_string_literal: true

class AddGroupEmailsDisabled < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  disable_ddl_transaction!

  def change
    add_column :namespaces, :emails_disabled, :boolean
  end
end
