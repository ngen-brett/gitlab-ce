# frozen_string_literal: true

require 'spec_helper'

describe 'task completion status response' do
  set(:user) { create(:user) }
  set(:project) do
    create(:project, :public, creator_id: user.id, namespace: user.namespace)
  end

  shared_examples 'taskable completion status provider' do |path|
    samples = [
        {
            description: '',
            expected_count: 0,
            expected_completed_count: 0
        },
        {
            description: 'Lorem ipsum',
            expected_count: 0,
            expected_completed_count: 0
        },
        {
            description: %{- [ ] task 1
              - [x] task 2 },
            expected_count: 2,
            expected_completed_count: 1
        },
        {
            description: %{- [ ] task 1
              - [ ] task 2 },
            expected_count: 2,
            expected_completed_count: 0
        },
        {
            description: %{- [x] task 1
              - [x] task 2 },
            expected_count: 2,
            expected_completed_count: 2
        },
        {
            description: %{- [ ] task 1},
            expected_count: 1,
            expected_completed_count: 0
        },
        {
            description: %{- [x] task 1},
            expected_count: 1,
            expected_completed_count: 1
        }
    ]
    samples.each do |sample_data|
      it "returns a valid task list status #{sample_data}" do
        taskable.update!(description: sample_data[:description])

        get api(path, user)

        expect(response).to have_gitlab_http_status(200)

        taskable_response = json_response.find { |item| item['id'] == taskable.id }
        expect(taskable_response).not_to be_nil

        task_completion_status = taskable_response['task_completion_status']
        expect(task_completion_status['count']).to be(sample_data[:expected_count])
        expect(task_completion_status['completed_count']).to be(sample_data[:expected_completed_count])
      end
    end
  end

  context 'task list completion status for issues' do
    it_behaves_like 'taskable completion status provider', '/issues' do
      let(:taskable) do
        create(:issue,
                              project: project,
                              author: user)
      end
    end
  end

  context 'task list completion status for merge_requests' do
    it_behaves_like 'taskable completion status provider', '/merge_requests' do
      let(:taskable) { create(:merge_request, source_project: project, target_project: project, author: user) }
    end
  end
end
