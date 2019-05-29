# frozen_string_literal: true

require 'spec_helper'

describe 'task completion status response' do
  set(:user) { create(:user) }
  set(:project) do
    create(:project, :public, creator_id: user.id, namespace: user.namespace)
  end

  shared_examples 'taskable completion status provider' do |path|
    samples = [
        ['', 0, 0],
        ['Lorem ipsum', 0, 0],
        [%{- [ ] task 1
              - [x] task 2 }, 2, 1],
        [%{- [ ] task 1
              - [ ] task 2 }, 2, 0],
        [%{- [x] task 1
              - [x] task 2 }, 2, 2],
        [%{- [ ] task 1}, 1, 0],
        [%{- [x] task 1}, 1, 1]
    ]
    samples.each do |sample_data|
      it "returns a valid task list status #{sample_data}" do
        description = sample_data[0]
        expected_count = sample_data[1]
        expected_completed_count = sample_data[2]

        taskable.update!(description: description)

        get api(path, user)

        expect(response).to have_gitlab_http_status(200)

        taskable_response = json_response.find { |item| item['id'] == taskable.id }
        expect(taskable_response).not_to be_nil

        task_completion_status = taskable_response['task_completion_status']
        expect(task_completion_status['count']).to be(expected_count)
        expect(task_completion_status['completed_count']).to be(expected_completed_count)
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
