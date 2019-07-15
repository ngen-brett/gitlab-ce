# frozen_string_literal: true

class AddIndexesOnDesignManagementDesignsVersionsEvent < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index(:design_management_designs_versions, :event)
  end

  def down
    remove_concurrent_index(:design_management_designs_versions, :event)
  end
end
