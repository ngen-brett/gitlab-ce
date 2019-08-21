# frozen_string_literal: true

require 'spec_helper'

describe Projects::OpenMergeRequestsCountService do
  set(:project) { create(:project) }
  subject { described_class.new(project) }

  it_behaves_like 'a counter caching service'

  describe '#count' do
    it 'returns the number of open merge requests' do
      create(:merge_request,
             :opened,
             source_project: project,
             target_project: project)

      expect(subject.count).to eq(1)
    end
  end
end
