# frozen_string_literal: true

require 'spec_helper'

describe AutoMerge::MergeTrainService do
  include ExclusiveLeaseHelpers

  let(:project) { create(:project, :repository) }
  let(:user) { create(:user) }
  let(:service) { described_class.new(project, user, params) }
  let(:params) { {} }

  let(:merge_request) do
    create(:merge_request, :with_merge_request_pipeline,
      source_project: project, target_project: project)
  end

  before do
    project.add_maintainer(user)

    allow(AutoMergeProcessWorker).to receive(:perform_async) { }

    stub_licensed_features(merge_trains: true, merge_pipelines: true)
    project.update!(merge_trains_enabled: true, merge_pipelines_enabled: true)
  end

  describe '#execute' do
    subject { service.execute(merge_request) }

    it 'enables auto merge on the merge request' do
      subject

      merge_request.reload
      expect(merge_request.auto_merge_enabled).to be_truthy
      expect(merge_request.merge_user).to eq(user)
      expect(merge_request.auto_merge_strategy).to eq(AutoMergeService::STRATEGY_MERGE_TRAIN)
    end

    it 'creates merge train' do
      subject

      merge_request.reload
      expect(merge_request.merge_train).to be_present
      expect(merge_request.merge_train.user).to eq(user)
    end

    it 'creates system note' do
      expect(SystemNoteService)
        .to receive(:merge_train).with(merge_request, project, user, instance_of(MergeTrain))

      subject
    end

    it 'returns result code' do
      is_expected.to eq(:merge_train)
    end

    context 'when failed to save the record' do
      before do
        allow(merge_request).to receive(:save) { false }
      end

      it 'returns result code' do
        is_expected.to eq(:failed)
      end
    end
  end

  describe '#process' do
    subject { service.process(merge_request) }

    let(:merge_request) do
      create(:merge_request, :on_train,
        source_project: project, source_branch: 'feature',
        target_project: project, target_branch: 'master',
        merge_status: 'unchecked')
    end

    let(:ci_yaml) do
      { test: { stage: 'test', script: 'echo', only: ['merge_requests'] } }
    end

    before do
      stub_ci_pipeline_yaml_file(YAML.dump(ci_yaml))
    end

    context 'when pipeline for merge train is not created yet' do
      it 'creates pipeline for merge train' do
        expect { subject }
          .to change { merge_request.merge_train.reload.pipeline }.from(nil).to(instance_of(Ci::Pipeline))
      end

      context 'when merge request is  not mergeable' do
        before do
          merge_request.update!(title: merge_request.wip_title)
        end

        it 'cancels the auto merge' do
          expect(service).to receive(:cancel).with(merge_request, reason: 'merge request is not mergeable')

          subject
        end
      end
    end

    context 'when pipeline for merge train has already been created' do
      before do
        merge_request.merge_train.update!(pipeline: create_pipeline_for(merge_request))
      end

      it 'does not create pipeline for merge train again' do
        expect { subject }.not_to change { Ci::Pipeline.count }
      end

      context 'when merge request is not mergeable' do
        before do
          merge_request.update!(title: merge_request.wip_title)
        end

        it 'cancels the auto merge' do
          expect(service).to receive(:cancel).with(merge_request, reason: 'merge request is not mergeable')

          subject
        end
      end

      context 'when merge trains project level option is disabled' do
        before do
          project.update!(merge_trains_enabled: false)
        end

        it 'cancels the auto merge' do
          expect(service).to receive(:cancel).with(merge_request, reason: 'project disabled merge trains')

          subject
        end
      end
    end

    context 'when pipeline for merge train has already been created and finished' do
      let(:pipeline) { create_pipeline_for(merge_request) }

      before do
        merge_request.merge_train.update!(pipeline: pipeline)
        pipeline.update_column(:status, 'success')

        expect(merge_request).not_to be_merged
        expect(merge_request.merge_train).to be_present
      end

      it 'merges the merge request' do
        expect_any_instance_of(MergeRequests::MergeService) do |merge_service|
          expect(merge_service).to receive(:execute).with(merge_request).and_call_original
        end

        subject

        merge_request.reload
        expect(merge_request).to be_merged
      end

      it 'destroys the associated merge train' do
        subject

        merge_request.reload
        expect(merge_request.merge_train).to be_nil
      end

      context 'when the pipeline failed' do
        before do
          pipeline.update_column(:status, 'failed')
        end

        it 'cancels the auto merge' do
          expect(service).to receive(:cancel).with(merge_request, reason: 'pipeline did not succeed')

          subject
        end
      end

      context 'when merge failed' do
        before do
          allow_any_instance_of(MergeRequest).to receive(:merged?) { false }
        end

        it 'cancels the auto merge' do
          expect(service).to receive(:cancel).with(merge_request, reason: 'failed to merge')

          subject
        end
      end
    end

    context 'when the merge request is a follower' do
      before do
        create(:merge_request, :on_train,
          source_project: project, source_branch: 'signed-commits',
          target_project: project, target_branch: 'master',
          merge_status: 'unchecked')

        expect(merge_request.merge_train).to be_follower_in_train
      end

      context 'when pipeline for merge train is not created yet' do
        it 'does not create pipeline for the merge train' do
          expect { subject }.not_to change { merge_request.merge_train.reload.pipeline }
        end
      end
    end

    context 'when the other thread has already been processing' do
      before do
        stub_exclusive_lease_taken("merge_train:#{merge_request.target_project_id}-#{merge_request.target_branch}")
      end

      it 'raises an error' do
        expect { subject }.to raise_error(Gitlab::ExclusiveLeaseHelpers::FailedToObtainLockError)
      end
    end
  end

  describe '#cancel' do
    subject { service.cancel(merge_request) }

    let(:merge_request) do
      create(:merge_request, :on_train,
        source_project: project, source_branch: 'feature',
        target_project: project, target_branch: 'master')
    end

    it 'cancels auto merge on the merge request' do
      subject

      merge_request.reload
      expect(merge_request).not_to be_auto_merge_enabled
      expect(merge_request.merge_user).to be_nil
      expect(merge_request.merge_params).not_to include('should_remove_source_branch')
      expect(merge_request.merge_params).not_to include('commit_message')
      expect(merge_request.merge_params).not_to include('squash_commit_message')
      expect(merge_request.merge_params).not_to include('auto_merge_strategy')
      expect(merge_request.merge_train).not_to be_present
    end

    it 'writes system note to the merge request' do
      expect(SystemNoteService)
        .to receive(:cancel_merge_train).with(merge_request, project, user, anything)

      subject
    end
  end

  describe '#available_for?' do
    subject { service.available_for?(merge_request) }

    let(:pipeline) { double }

    before do
      allow(merge_request).to receive(:mergeable?) { true }
      allow(merge_request).to receive(:for_fork?) { false }
      allow(merge_request).to receive(:actual_head_pipeline) { pipeline }
      allow(pipeline).to receive(:complete?) { true }
    end

    it { is_expected.to be_truthy }

    context 'when merge trains project option is disabled' do
      before do
        project.update!(merge_trains_enabled: false)
      end

      it { is_expected.to be_falsy }
    end

    context 'when merge request is not mergeable' do
      before do
        allow(merge_request).to receive(:mergeable?) { false }
      end

      it { is_expected.to be_falsy }
    end

    context 'when merge request is submitted from a forked project' do
      before do
        allow(merge_request).to receive(:for_fork?) { true }
      end

      it { is_expected.to be_falsy }
    end

    context 'when the head pipeline of the merge request has not finished' do
      before do
        allow(pipeline).to receive(:complete?) { false }
      end

      it { is_expected.to be_falsy }
    end
  end

  def create_pipeline_for(merge_request)
    MergeRequests::CreatePipelineService.new(project, user).execute(merge_request)
  end
end
