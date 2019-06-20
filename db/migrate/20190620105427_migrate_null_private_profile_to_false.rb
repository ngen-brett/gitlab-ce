# frozen_string_literal: true

class MigrateNullPrivateProfileToFalse < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    change_column_default :users, :private_profile, false

    BackgroundMigrationWorker.perform_in(5.minutes, 'MigrateNullPrivateProfileToFalse')
  end

  def down
    # no action
  end
end
