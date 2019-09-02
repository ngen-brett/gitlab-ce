# frozen_string_literal: true

class CreateZoomMeetings < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :zoom_meetings do |t|
      t.integer :project_id, null: false, index: true
      t.integer :issue_id, null: false, index: true
      t.string :url, limit: 255
      t.timestamps_with_timezone null: false

      t.foreign_key :projects, on_delete: :cascade
      t.foreign_key :issues, on_delete: :cascade
    end
  end
end
