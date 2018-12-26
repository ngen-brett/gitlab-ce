require 'spec_helper'

describe API::Releases do
  let(:project) { create(:project, :repository) }
  let(:maintainer) { create(:user) }
  let(:repoter) { create(:user) }
  let(:non_project_member) { create(:user) }
  let(:commit) { create(:commit, project: project) }

  before do
    project.add_maintainer(maintainer)
    project.add_reporter(repoter)

    project.repository.add_tag(maintainer, 'v0.1', commit.id)
    project.repository.add_tag(maintainer, 'v0.2', commit.id)
  end

  describe 'GET /projects/:id/releases' do
    context 'when there are two releases' do
      let!(:release_1) { create(:release, project: project, tag: 'v0.1', author: maintainer) }
      let!(:release_2) { create(:release, project: project, tag: 'v0.2', author: maintainer) }

      it 'returns 200 HTTP status' do
        get api("/projects/#{project.id}/releases", maintainer)

        expect(response).to have_gitlab_http_status(:ok)
      end

      it 'returns releases ordered by created_at' do
        get api("/projects/#{project.id}/releases", maintainer)

        expect(json_response.count).to eq(2)
        expect(json_response.first['tag_name']).to eq(release_2.tag)
        expect(json_response.second['tag_name']).to eq(release_1.tag)
      end

      it 'matches response schema' do
        get api("/projects/#{project.id}/releases", maintainer)

        expect(response).to match_response_schema('releases')
      end
    end

    context 'when tag does not exist in git repository' do
      let!(:release) { create(:release, project: project, tag: 'v1.1.5') }

      it 'returns empty list' do
        get api("/projects/#{project.id}/releases", maintainer)

        expect(json_response.count).to eq(1)
        expect(json_response.first['tag_name']).to eq(release_2.tag)
        expect(json_response.second['tag_name']).to eq(release_1.tag)
      end
    end

    context 'when user does not have permission' do

    end
  end

  describe 'GET /projects/:id/releases/:tag_name' do
    # TODO:
  end

  describe 'POST /projects/:id/releases' do
    # TODO:
  end

  describe 'PUT /projects/:id/releases/:tag_name' do
    # TODO:
  end

  describe 'DELETE /projects/:id/releases/:tag_name' do
    # TODO:
  end
end
