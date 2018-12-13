# frozen_string_literal: true

require 'spec_helper'

describe ErrorTracking::ErrorTrackingSetting do
  it { is_expected.to belong_to(:project) }

  describe '#token' do
    it 'encrypts the value' do
      subject.token = 'value'

      expect(subject.encrypted_token).not_to be_nil
      expect(subject.encrypted_token_iv).not_to be_nil
    end
  end
end
