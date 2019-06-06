# frozen_string_literal: true

class EncryptFeatureFlagsClientsTokens < ActiveRecord::Migration[5.1]
  DOWNTIME = false

  class FeatureFlagsClient < ActiveRecord::Base
    self.table_name = 'operations_feature_flags_clients'
  end if table_exists?(:operations_feature_flags_clients)

  def up
    if table_exists?(:operations_feature_flags_clients)
      say_with_time("Encrypting tokens from operations_feature_flags_clients") do
        FeatureFlagsClient.where('token_encrypted is NULL AND token IS NOT NULL').find_each do |feature_flags_client|
          token_encrypted = Gitlab::CryptoHelper.aes256_gcm_encrypt(feature_flags_client.token)
          feature_flags_client.update!(token_encrypted: token_encrypted)
        end
      end
    end
  end

  def down
  end
end
