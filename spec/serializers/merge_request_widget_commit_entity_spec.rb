require 'spec_helper'

describe MergeRequestWidgetCommitEntity do
  let(:project) { create(:project, :repository) }
  let(:commit) { project.commit }
  let(:request) { double('request') }

  let(:entity) do
    described_class.new(commit, request: request)
  end

  context 'as json' do
    subject { entity.as_json }

    it 'exposes needed attributes' do
      expect(subject).to include(:message, :sha, :title)
    end
  end
end
