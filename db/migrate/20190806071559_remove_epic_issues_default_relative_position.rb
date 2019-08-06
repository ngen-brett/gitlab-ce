# frozen_string_literal: true

class RemoveEpicIssuesDefaultRelativePosition < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    change_column_null :epic_issues, :relative_position, true
    change_column_default :epic_issues, :relative_position, nil
  end

  def down
    change_column_default :epic_issues, :relative_position, 1073741823
    change_column_null :epic_issues, :relative_position, false
  end
end
