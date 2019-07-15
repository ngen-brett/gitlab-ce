# frozen_string_literal: true

class AddProjectEmailsDisabled < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  disable_ddl_transaction!

  def change
    add_column :projects, :emails_disabled, :boolean
  end
end
