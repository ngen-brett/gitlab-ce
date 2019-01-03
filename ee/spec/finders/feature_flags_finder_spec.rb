require 'spec_helper'

describe FeatureFlagsFinder do
  let(:finder) { described_class.new(project, user, params) }
  let(:project) { create(:project) }
  let(:user) { developer }
  let(:developer) { create(:user) }
  let(:reporter) { create(:user) }
  let(:params) { {} }

  before do
    stub_licensed_features(feature_flags: true)

    project.add_developer(user)
    project.add_reporter(user)
  end

  describe '#execute' do
    subject { finder.execute }

    let!(:feature_flag) { create(:operations_feature_flag, project: project) }

    it 'returns a feature flag' do
      is_expected.to eq([feature_flag])
    end

    context 'when user is a reporter' do
      let(:user) { reporter }

      it 'returns an empty list' do
        is_expected.to be_empty
      end
    end

    context 'when scope is given' do
      # TODO:
    end
  end
end