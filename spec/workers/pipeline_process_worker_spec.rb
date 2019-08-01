# frozen_string_literal: true

require 'spec_helper'

describe PipelineProcessWorker, :clean_gitlab_redis_shared_state do
  include ExclusiveLeaseHelpers

  describe '#perform' do
    subject { worker.perform(pipeline.id) }

    let(:pipeline) { create(:ci_pipeline) }
    let(:worker) { described_class.new }

    context 'when pipeline exists' do
      it 'processes pipeline' do
        expect_any_instance_of(Ci::Pipeline).to receive(:process!)

        described_class.new.perform(pipeline.id)
      end

      context 'when the other sidekiq job has already been processing on the pipeline' do
        before do
          stub_exclusive_lease_taken("batch_pop_queueing:lock:pipeline-process:#{pipeline.id}")
        end

        it 'enqueues the pipeline id to the queue and does not process' do
          expect_next_instance_of(Gitlab::BatchPopQueueing) do |queue|
            expect(queue).to receive(:enqueue).with([pipeline.id], anything)
          end

          expect_any_instance_of(Ci::Pipeline).not_to receive(:process!)

          subject
        end
      end

      context 'when there are some items are enqueued during the current process' do
        before do
          allow_any_instance_of(Gitlab::BatchPopQueueing).to receive(:safe_execute) do
            { status: :finished, new_items: [pipeline.id] }
          end
        end

        it 're-executes PipelineProcessWorker asynchronously' do
          expect(PipelineProcessWorker).to receive(:perform_async).with(pipeline.id)

          subject
        end
      end
    end

    context 'when pipeline does not exist' do
      it 'does not raise exception' do
        expect { described_class.new.perform(123) }
          .not_to raise_error
      end
    end

    context 'when pipeline_process_worker_efficient_perform feature flag is disabled' do
      before do
        stub_feature_flags(pipeline_process_worker_efficient_perform: false)
      end

      it 'processes legacy perform' do
        expect(worker).to receive(:legacy_perform).once

        subject
      end
    end
  end
end
