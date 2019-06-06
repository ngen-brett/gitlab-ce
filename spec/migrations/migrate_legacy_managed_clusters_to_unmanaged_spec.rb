# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20190606163724_migrate_legacy_managed_clusters_to_unmanaged.rb')

describe MigrateLegacyManagedClustersToUnmanaged, :migration do
  let(:cluster_type) { :project }
  let(:created_at) { 1.hour.ago }

  let!(:cluster) { create(:cluster, cluster_type, managed: true, created_at: created_at) }

  it 'marks the cluster as unmanaged' do
    migrate!
    expect(cluster.reload).to_not be_managed
  end

  context 'cluster is not project type' do
    let(:cluster_type) { :group }

    it 'does not update the cluster' do
      migrate!
      expect(cluster.reload).to be_managed
    end
  end

  context 'cluster has a kubernetes namespace associated' do
    before do
      create(:cluster_kubernetes_namespace, cluster: cluster)
    end

    it 'does not update the cluster' do
      migrate!
      expect(cluster.reload).to be_managed
    end
  end

  context 'cluster was recently created' do
    let(:created_at) { 2.minutes.ago }

    it 'does not update the cluster' do
      migrate!
      expect(cluster.reload).to be_managed
    end
  end
end
