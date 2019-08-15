# frozen_string_literal: true

class CreateGithubPullRequestEvents < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def change
    create_table :github_pull_request_events do |t|
      t.timestamps_with_timezone null: false
      t.references :project, null: false, foreign_key: { on_delete: :cascade }
      t.string :branch_name, null: false, limit: 255, index: true
      t.string :status, null: false, limit: 30

      t.index [:project_id, :branch_name], unique: true
    end
  end
end
