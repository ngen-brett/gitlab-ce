require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20190606175050_encrypt_feature_flags_clients_tokens.rb')

describe EncryptFeatureFlagsClientsTokens, :migration do
  let(:migration) { described_class.new }
  let(:feature_flags_clients) { table(:operations_feature_flags_clients) }
  let(:projects) { table(:projects) }

  describe '#up' do
    it 'keeps plaintext token the same and populates token_encrypted if not present' do
      if migration.table_exists?(:operations_feature_flags_clients)
        project = projects.create!(id: 123, name: 'gitlab1', path: 'gitlab1', namespace_id: 123)
        feature_flags_client = feature_flags_clients.create!(project_id: project.id, token: 'secret-token-1')

        migration.up

        expect(feature_flags_client.reload.token).to eq('secret-token-1')
        expect(feature_flags_client.reload.token_encrypted).to eq(Gitlab::CryptoHelper.aes256_gcm_encrypt('secret-token-1'))
      end
    end
  end
end
