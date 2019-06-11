# frozen_string_literal: true

require 'spec_helper'

describe ContainerRegistries::CleanupContainerRepositoryService do
  include ExclusiveLeaseHelpers

  let(:repository) { create(:container_repository) }
  let(:project) { repository.project }
  let(:user) { project.owner }
  let(:params) { { key: 'value' } }
  let(:lease_key) { "container_repository:cleanup_tags:#{repository.id}" }
  let(:lease_timeout) { ContainerRegistries::CleanupContainerRepositoryService::LEASE_TIMEOUT }

  subject { described_class.new(user, repository, params) }

  describe '#execute' do
    let(:worker) { instance_double(CleanupContainerRepositoryWorker) }
    context 'when there is not already a lease' do
      before do
        allow(CleanupContainerRepositoryWorker).to receive(:perform)
          .with(user.id, repository.id, params).and_return(worker)
      end
      it 'schedules the cleanup worker' do
        stub_exclusive_lease(lease_key, timeout: lease_timeout)

        expect(subject.execute).to be true
      end
    end

    context 'when executed twice in short period' do
      before do
        stub_exclusive_lease_taken(lease_key, timeout: lease_timeout)
      end
      it 'executes service only for the first time' do
        expect(subject.execute).to be false
      end
    end
  end
end
