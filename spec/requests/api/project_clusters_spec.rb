# frozen_string_literal: true
require 'spec_helper'

describe API::ProjectClusters do
  let(:current_user) { create(:user) }
  let(:non_member) { create(:user) }
  let(:project) { create(:project, :repository) }

  before do
    project.add_maintainer(current_user)
  end

  describe 'GET /projects/:id/clusters' do
    let(:clusters) do
      create_list(:cluster, 5,
                  :provided_by_gcp,
                  :project,
                  projects: [project])
    end

    let(:extra_cluster) { create(:cluster, :provided_by_gcp, :project) }

    before do
      clusters
      extra_cluster
    end

    context 'nonauthorized user' do
      it 'should respond with 404' do
        get api("/projects/#{project.id}/clusters", non_member)

        expect(response).to have_gitlab_http_status(404)
      end
    end

    context 'authorized user' do
      before do
        get api("/projects/#{project.id}/clusters", current_user)
      end

      it 'should respond with 200' do
        expect(response).to have_gitlab_http_status(200)
      end

      it 'should include pagination headers' do
        expect(response).to include_pagination_headers
      end

      it 'should include authorized clusters' do
        cluster_ids = json_response.map { |cluster| cluster['id'] }

        expect(cluster_ids).to match_array(clusters.pluck(:id))
        expect(cluster_ids).not_to include(extra_cluster.id)
      end
    end
  end

  describe 'GET /projects/:id/clusters/:cluster_id' do
    let!(:cluster) do
      create(:cluster,
             :provided_by_gcp,
             :project,
             projects: [project])
    end

    context 'non-authorized user' do
      it 'should respond with 404' do
        get api("/projects/#{project.id}/clusters/#{cluster.id}", non_member)

        expect(response).to have_gitlab_http_status(404)
      end
    end

    context 'authorized user' do
      it 'returns specific cluster' do
        get api("/projects/#{project.id}/clusters/#{cluster.id}", current_user)

        expect(json_response["id"]).to eq(cluster.id)
      end

      context 'for non existing cluster' do
        it 'returns 404' do
          get api("/projects/#{project.id}/clusters/123", current_user)

          expect(response).to have_gitlab_http_status(404)
        end
      end
    end
  end
end
