require 'spec_helper'

describe ProjectInvitedGroupsMembersFinder, '#execute' do
  let(:project) { create(:project, :public) }

  let(:group1) { create(:group, :public, :access_requestable) }
  let(:nested_group) { create(:group, parent: group1) }
  let(:group2) { create(:group) }

  let(:developer1) { create(:user) }
  let(:developer2) { create(:user) }
  let(:nested_user) { create(:user) }
  let(:access_requester) { create(:user) }

  let!(:project_group_link1) { create(:project_group_link, project: project, group: nested_group) }
  let!(:project_group_link2) { create(:project_group_link, project: project, group: group2) }

  it 'returns all the members for the project invited_groups including members inherited from ancestor groups excluding access requester' do
    member1 = group1.add_developer(developer1)
    group1.request_access(access_requester)
    member2 = nested_group.add_developer(nested_user)
    member3 = group2.add_developer(developer2)

    expect(described_class.new(project).execute).to contain_exactly(member1, member2, member3)
  end
end
