# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::BackgroundMigration::MigrateNullPrivateProfileToFalse, :migration, schema: 20190620105427 do
  it 'correctly migrates nil private_profile to false' do
    private_profile_true = create(:user, private_profile: true)
    private_profile_false = create(:user, private_profile: false)
    private_profile_nil = create(:user, private_profile: nil)

    described_class.new.perform

    private_profile_true.reload
    private_profile_false.reload
    private_profile_nil.reload

    expect(private_profile_true.private_profile).to eq true
    expect(private_profile_false.private_profile).to eq false
    expect(private_profile_nil.private_profile).to eq false
  end
end

