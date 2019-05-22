# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class MigrateIssueTrackersData < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  DOWNTIME = false
  MIGRATION = 'MigrateIssueTrackersSensitiveData'

  def up
    BackgroundMigrationWorker.perform_async(MIGRATION)
  end

  # not needed
  def down
  end

end
