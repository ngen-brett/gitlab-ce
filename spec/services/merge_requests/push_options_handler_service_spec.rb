# frozen_string_literal: true

require 'spec_helper'

describe MergeRequests::PushOptionsHandlerService do
  let(:user) { create(:user) }
  let(:project) { create(:project, :public, :repository) }
  let(:service) { described_class.new(project, user, changes, push_options) }
  let(:source_branch) { "merge-test" }
  let(:new_branch_changes) { "#{Gitlab::Git::BLANK_SHA} 570e7b2abdd848b95f2f578043fc23bd6f6fd24d refs/heads/#{source_branch}" }
  let(:existing_branch_changes) { "d14d6c0abdd253381df51a723d58691b2ee1ab08 570e7b2abdd848b95f2f578043fc23bd6f6fd24d refs/heads/#{source_branch}" }
  let(:deleted_branch_changes) { "d14d6c0abdd253381df51a723d58691b2ee1ab08 #{Gitlab::Git::BLANK_SHA} refs/heads/#{source_branch}" }
  let(:default_branch_changes) { "d14d6c0abdd253381df51a723d58691b2ee1ab08 570e7b2abdd848b95f2f578043fc23bd6f6fd24d refs/heads/#{project.default_branch}" }

  before do
    project.add_developer(user)
  end

  shared_examples_for 'a service that can create an MR' do
    subject { service.results.first.merge_request }

    it 'creates an MR' do
      service.execute

      expect(service.results.size).to eq(1)
      expect(subject).to be_valid
    end

    it 'creates a new MR using the correct branch' do
      branch = push_options[:target] || project.default_branch

      service.execute

      expect(subject.target_branch).to eq(branch)
    end

    it 'assigns the MR to the user' do
      service.execute

      expect(subject.assignee).to eq(user)
    end

    it 'creates an MR with title and description taken from first commit' do
      skip

      # service.execute

      # expect(subject.title).to eq('x')
      # expect(subject.description).to eq('y')
    end
  end

  shared_examples_for 'a service that can set the target of an MR' do
    subject { service.results.first.merge_request }

    it 'sets the target_branch' do
      service.execute

      expect(subject.target_branch).to eq('foo')
    end
  end

  shared_examples_for 'a service that does not create an MR' do
    it do
      service.execute

      results = service.results.select { |r| r.success && r.action == :create }

      expect(results).to be_empty
    end
  end

  shared_examples_for 'a service that does nothing' do
    include_examples 'a service that does not create an MR'

    it 'does not update an MR' do
      # of any instance of MergeRequests::UpdateService not to receive update
      # and then apply the same thing in the positive test
      service.execute

      results = service.results.select { |r| r.success && r.action == :update }

      expect(results).to be_empty
    end
  end

  describe '`create` push option' do
    let(:push_options) { { create: true } }

    context 'with a new branch' do
      let(:changes) { new_branch_changes }

      it_behaves_like 'a service that can create an MR'
    end

    context 'with an existing branch but no MR' do
      let(:changes) { existing_branch_changes }

      it_behaves_like 'a service that can create an MR'
    end

    context 'with an existing branch that has an MR open' do
      let(:changes) { existing_branch_changes }
      let!(:merge_request) { create(:merge_request, source_project: project, source_branch: source_branch)}

      it_behaves_like 'a service that does nothing'
    end

    context 'with a deleted branch' do
      let(:changes) { deleted_branch_changes }

      it_behaves_like 'a service that does nothing'
    end

    context 'with the project default branch' do
      let(:changes) { default_branch_changes }

      it_behaves_like 'a service that does nothing'
    end
  end

  describe '`target` push option' do
    let(:push_options) { { target: 'foo' } }
    let(:subject) { service.results.first.merge_request }

    context 'with a new branch' do
      let(:changes) { new_branch_changes }

      it_behaves_like 'a service that can create an MR'
      it_behaves_like 'a service that can set the target of an MR'
    end

    context 'with an existing branch but no MR' do
      let(:changes) { existing_branch_changes }

      it_behaves_like 'a service that can create an MR'
      it_behaves_like 'a service that can set the target of an MR'
    end

    context 'with an existing branch that has an MR open' do
      let(:changes) { existing_branch_changes }
      let!(:merge_request) { create(:merge_request, source_project: project, source_branch: source_branch)}

      it_behaves_like 'a service that does not create an MR'
      it_behaves_like 'a service that can set the target of an MR'
    end

    context 'with a deleted branch' do
      let(:changes) { deleted_branch_changes }

      it_behaves_like 'a service that does nothing'
    end

    context 'with the project default branch' do
      let(:changes) { default_branch_changes }

      it_behaves_like 'a service that does nothing'
    end
  end

  describe 'multiple pushed branches' do
    let(:push_options) { { create: true } }
    let(:changes) do
      [
        new_branch_changes,
        "#{Gitlab::Git::BLANK_SHA} 570e7b2abdd848b95f2f578043fc23bd6f6fd24d refs/heads/second-branch"
      ]
    end

    it 'creates a MR per branch' do
      service.execute

      expect(service.results.size).to eq(2)
    end

    context 'when there are too many pushed branches' do
      let(:limit) { MergeRequests::PushOptionsHandlerService::LIMIT }
      let(:changes) do
        TestEnv::BRANCH_SHA.to_a[0..limit].map do |x|
          "#{Gitlab::Git::BLANK_SHA} #{x.first} refs/heads/#{x.last}"
        end
      end

      it 'throws an error' do
        expect{ service.execute }.to raise_error(
          MergeRequests::PushOptionsHandlerService::Error,
          "Too many branches pushed (#{limit + 1} were pushed, limit is #{limit})"
        )
      end
    end
  end

  describe 'invalid push options' do
    let(:push_options) { { invalid: true } }
    let(:changes) { new_branch_changes }

    it 'throws an error' do
      expect { service.execute }.to raise_error(
        MergeRequests::PushOptionsHandlerService::Error,
        'Push options are not valid'
      )
    end
  end

  describe 'no user' do
    let(:user) { nil }
    let(:push_options) { { create: true } }
    let(:changes) { new_branch_changes }

    it 'throws an error' do
      expect { service.execute }.to raise_error(
        MergeRequests::PushOptionsHandlerService::Error,
        'User is required'
      )
    end
  end

  describe 'unauthorized user' do
    let(:push_options) { { create: true } }
    let(:changes) { new_branch_changes }

    it 'throws an error' do
      Members::DestroyService.new(user).execute(ProjectMember.find_by!(user_id: user.id))

      expect { service.execute }.to raise_error(Gitlab::Access::AccessDeniedError)
    end
  end

  describe 'when MRs are not enabled' do
    let(:push_options) { { create: true } }
    let(:changes) { new_branch_changes }

    it 'throws an error' do
      expect(project).to receive(:merge_requests_enabled?).and_return(false)

      expect { service.execute }.to raise_error(
        MergeRequests::PushOptionsHandlerService::Error,
        'Merge requests are not enabled for project'
      )
    end
  end

  # private

  # def generate_changes(n)
  #   TestEnv::BRANCH_SHA.to_a[0..n-1].map do |x|
  #     "#{Gitlab::Git::BLANK_SHA} #{x.first} refs/heads/#{x.last}"
  #   end
  # end
end
