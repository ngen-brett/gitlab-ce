require 'spec_helper'

describe IdentityProviderPolicy do
  subject(:policy) { described_class.new(user, provider) }
  let(:user) { User.new }
  let(:provider) { :a_provider }

  describe '#rules' do
    it 'allows link and unlink' do
      expect(policy).to be_allowed(:link)
      expect(policy).to be_allowed(:unlink)
    end

    context 'when user is anonymous' do
      let(:user) { nil }

      it 'prohibits link and unlink' do
        expect(policy).to be_disallowed(:link)
        expect(policy).to be_disallowed(:unlink)
      end
    end

    %w[saml cas3].each do |provider_name|
      context "when provider is #{provider_name}" do
        let(:provider) { provider_name }

        it 'allows link and prohibits unlink' do
          expect(policy).to be_allowed(:link)
          expect(policy).to be_disallowed(:unlink)
        end
      end
    end
  end
end
