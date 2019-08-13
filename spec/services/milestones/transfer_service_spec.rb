# frozen_string_literal: true

require 'spec_helper'

describe Milestones::TransferService do
  let(:user) { create(:user) }

  describe '#execute' do
    let(:user)    { create(:admin) }
    let(:group) { create(:group) }
    let(:group2) { create(:group) }
    let(:project) { create(:project, namespace: group2) }
    let(:group_milestone) { create(:milestone, group: group2)}
    let(:group_milestone2) { create(:milestone, group: group2)}
    let(:project_milestone) { create(:milestone, project: project)}
    let!(:issue1) { create(:issue, project: project, milestone: group_milestone) }
    let!(:issue2) { create(:issue, project: project, milestone: project_milestone) }
    let!(:merge_request1) { create(:merge_request, source_project: project, source_branch: 'branch-1', milestone: group_milestone) }
    let!(:merge_request2) { create(:merge_request, source_project: project, source_branch: 'branch-2', milestone: project_milestone) }

    subject(:service) { described_class.new(user, group2, project) }

    before do
      group.add_maintainer(user)
      project.add_maintainer(user)
      project.update!(group: group)
    end

    it 'recreates the missing group milestones at project level' do
      expect { service.execute }.to change(project.milestones, :count).by(1)
    end

    it 'applies new project milestone to issues with group milestone' do
      service.execute

      expect(issue1.reload.milestone).not_to eq(group_milestone)
      expect(issue1.reload.milestone.title).to eq(group_milestone.title)
      expect(issue1.reload.milestone.project_milestone?).to be_truthy
    end

    it 'does not apply new project milestone to issues with project milestone' do
      service.execute

      expect(issue2.reload.milestone).to eq(project_milestone)
    end

    it 'applies new project milestone to merge_requests with group milestone' do
      service.execute

      expect(merge_request1.reload.milestone).not_to eq(group_milestone)
      expect(merge_request1.reload.milestone.title).to eq(group_milestone.title)
      expect(merge_request1.reload.milestone.project_milestone?).to be_truthy
    end

    it 'does not apply new project milestone to issuables with project milestone' do
      service.execute

      expect(merge_request2.reload.milestone).to eq(project_milestone)
    end

    it 'does not recreate missing group milestones that are not applied to issues or merge requests' do
      service.execute

      expect(project.reload.milestones.pluck(:title)).to include(group_milestone.title)
      expect(project.reload.milestones.pluck(:title)).not_to include(group_milestone2.title)
    end
  end
end
