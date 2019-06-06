# frozen_string_literal: true

class AddIndexToOperationsFeatureFlagsClientsTokenEncrypted < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    if table_exists?(:operations_feature_flags_clients)
      add_concurrent_index :operations_feature_flags_clients, [:project_id, :token_encrypted],
        unique: true, name: "index_feature_flags_clients_on_project_id_and_token_encrypted"
    end
  end

  def down
    if table_exists?(:operations_feature_flags_clients)
      remove_concurrent_index_by_name :operations_feature_flags_clients, "index_feature_flags_clients_on_project_id_and_token_encrypted"
    end
  end
end
