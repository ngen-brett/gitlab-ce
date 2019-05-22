# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CreateIssueTrackerData < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :issue_tracker_data do |t|
      t.references :service, { null: false, foreign_key: { on_delete: :cascade }}
      t.string :encrypted_project_url
      t.string :encrypted_project_url_iv
      t.string :encrypted_issues_url
      t.string :encrypted_issues_url_iv
      t.string :encrypted_new_issue_url
      t.string :encrypted_new_issue_url_iv

      t.timestamps
    end
  end
end
