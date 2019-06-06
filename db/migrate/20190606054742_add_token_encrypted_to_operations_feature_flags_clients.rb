# frozen_string_literal: true

class AddTokenEncryptedToOperationsFeatureFlagsClients < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    if table_exists?(:operations_feature_flags_clients)
      add_column :operations_feature_flags_clients, :token_encrypted, :string
    end
  end
end
