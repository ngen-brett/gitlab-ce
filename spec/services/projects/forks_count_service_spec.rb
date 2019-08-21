# frozen_string_literal: true

require 'spec_helper'

describe Projects::ForksCountService do
  let(:project) { build(:project, id: 42) }
  subject { described_class.new(project) }

  it_behaves_like 'a counter caching service'

  describe '#count' do
    it 'returns the number of forks' do
      allow(subject).to receive(:uncached_count).and_return(1)

      expect(subject.count).to eq(1)
    end
  end
end
