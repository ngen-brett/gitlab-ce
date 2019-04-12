# frozen_string_literal: true

class AddMergeRequestBlocks < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :merge_request_blocks do |t|
      t.references :blocking_merge_request,
                   index: true, null: false,
                   foreign_key: { to_table: :merge_requests, on_delete: :cascade }

      t.references :blocked_merge_request,
                   index: true, null: false,
                   foreign_key: { to_table: :merge_requests, on_delete: :cascade }

      t.timestamps
    end
  end
end
