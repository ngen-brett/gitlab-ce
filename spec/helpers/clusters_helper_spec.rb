# frozen_string_literal: true

require 'spec_helper'

describe ClustersHelper do
  describe '#has_rbac_enabled?' do
    context 'when kubernetes platform is created' do
      let(:platform_kubernetes) { create(:cluster_platform_kubernetes, :rbac_enabled) }
      let(:cluster) { create(:cluster, :provided_by_gcp, platform_kubernetes: platform_kubernetes) }

      it 'returns kubernetes platform value' do
        expect(helper.has_rbac_enabled?(cluster)).to be_truthy
      end
    end

    context 'when kubernetes platform has not been created yet' do
      let(:cluster) { create(:cluster, :providing_by_gcp) }

      it 'delegates to cluster provider' do
        expect(helper.has_rbac_enabled?(cluster)).to be_truthy
      end

      context 'when ABAC cluster is created' do
        let(:cluster) { create(:cluster, :providing_by_gcp, :rbac_disabled) }

        it 'delegates to cluster provider' do
          expect(helper.has_rbac_enabled?(cluster)).to be_falsy
        end
      end
    end
  end
end
