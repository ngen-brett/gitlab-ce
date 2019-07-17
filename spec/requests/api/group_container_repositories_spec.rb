# frozen_string_literal: true

require 'spec_helper'

describe API::GroupContainerRepositories do
  include ExclusiveLeaseHelpers

  set(:group) { create(:group, :private) }
  set(:project) { create(:project, :private, group: group) }
  set(:reporter) { create(:user) }
  set(:guest) { create(:user) }

  let(:root_repository) { create(:container_repository, :root, project: project) }
  let(:test_repository) { create(:container_repository, project: project) }

  let(:api_user) { reporter }

  before do
    project.add_reporter(reporter)
    project.add_guest(guest)

    stub_feature_flags(container_registry_api: true)
    stub_container_registry_config(enabled: true)

    root_repository
    test_repository
  end

  shared_examples 'being disallowed' do |param|
    context "for #{param}" do
      let(:api_user) { public_send(param) }

      it 'returns access denied' do
        subject

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end

    context "for anonymous" do
      let(:api_user) { nil }

      it 'returns not found' do
        subject

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end

  describe 'GET /groups/:id/registry/repositories' do
    subject { get api("/groups/#{group.id}/registry/repositories", api_user) }

    it_behaves_like 'being disallowed', :guest

    context 'for reporter' do
      it 'returns a list of repositories' do
        subject

        expect(json_response.length).to eq(2)
        expect(json_response.map { |repository| repository['id'] }).to contain_exactly(
          root_repository.id, test_repository.id)
      end

      it 'returns a matching schema' do
        subject

        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to match_response_schema('registry/repositories')
      end
    end
  end

  describe 'GET /groups/:id/registry/repositories/tags' do
    subject { get api("/groups/#{group.id}/registry/repositories/tags", api_user) }

    it_behaves_like 'being disallowed', :guest

    context 'for reporter' do
      it 'returns a list of repositories and their tags' do
        subject

        expect(json_response.length).to eq(2)
        expect(json_response.map { |repository| repository['id'] }).to contain_exactly(
          root_repository.id, test_repository.id)
      end

      it 'returns a matching schema' do
        subject

        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to match_response_schema('registry/repositories_with_tags')
      end
    end
  end
end
