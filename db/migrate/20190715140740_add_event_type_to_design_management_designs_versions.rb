# frozen_string_literal: true

# This migration sets up a event enum on the DesignsVersions join table
class AddEventTypeToDesignManagementDesignsVersions < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column_with_default(:design_management_designs_versions, :event, :integer, default: 0)
  end

  def down
    remove_column(:design_management_designs_versions, :event)
  end
end
