require 'spec_helper'

describe 'autocomplete_sources' do
  set(:group) { create(:group) }
  set(:project) { create(:project, namespace: group) }
  set(:issue) { create(:issue, project: project) }
  set(:user) { create(:user) }

  describe 'GET /:namespace/:project/autocomplete_sources/members' do
    before do
      project.add_developer(user)
      login_as(user)
    end

    it 'returns a list of participants with their type' do
      get members_project_autocomplete_sources_path(project, type: issue.class.name, id: issue.id)

      all = json_response.first.symbolize_keys
      the_group = json_response[1].symbolize_keys
      the_user = json_response.last.symbolize_keys

      expect(all).to include(username: 'all', name: 'All Project and Group Members', count: 1)
      expect(the_group).to include(type: 'Group', username: group.full_path, name: group.full_name, avatar: group.avatar_url, count: 0)
      expect(the_user).to include(type: 'User', username: user.username, name: user.name, avatar: user.avatar_url)
    end
  end
end
