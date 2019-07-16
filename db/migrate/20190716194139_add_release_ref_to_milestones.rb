# frozen_string_literal: true

class AddReleaseRefToMilestones < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_reference :milestones, :release, index: true, foreign_key: { on_delete: :cascade }
  end
end
