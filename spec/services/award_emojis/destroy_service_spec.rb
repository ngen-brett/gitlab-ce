# frozen_string_literal: true

require 'spec_helper'

describe AwardEmojis::DestroyService do
  let(:user) { create(:user) }
  let(:project) { awardable.project }
  let(:awardable) { create(:note) }
  let(:name) { 'thumbsup' }
  subject(:service) { described_class.new(awardable, name, user) }

  describe '#execute' do
    shared_examples 'a service that destroys an award emoji' do
      it 'removes the emoji' do
        expect { service.execute }.to change { AwardEmoji.count }.by(-1)
      end

      it 'returns a success status' do
        result = service.execute

        expect(result[:status]).to eq(:success)
      end
    end

    context 'when user has not awarded an emoji to the awardable' do
      let(:second_user) { create(:user) }

      let!(:award) { create(:award_emoji, awardable: awardable, user: second_user) }

      it 'does not remove the emoji' do
        expect { service.execute }.not_to change { AwardEmoji.count }
      end

      it 'returns an error status' do
        result = service.execute

        expect(result[:status]).to eq(:error)
        expect(result[:http_status]).to eq(:forbidden)
      end

      context 'when user is an admin' do
        before do
          expect(user).to receive(:admin?).and_return(true)
        end

        it_behaves_like 'a service that destroys an award emoji'
      end
    end

    context 'when user has awarded an emoji to the awardable' do
      let!(:award) { create(:award_emoji, awardable: awardable, user: user) }

      it_behaves_like 'a service that destroys an award emoji'
    end
  end
end
