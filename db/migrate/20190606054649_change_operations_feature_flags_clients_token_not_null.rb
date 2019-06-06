# frozen_string_literal: true

class ChangeOperationsFeatureFlagsClientsTokenNotNull < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    if table_exists?(:operations_feature_flags_clients)
      change_column_null :operations_feature_flags_clients, :token, true
    end
  end

  def down
  end
end
