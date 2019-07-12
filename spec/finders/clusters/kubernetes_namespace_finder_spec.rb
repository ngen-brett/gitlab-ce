require 'spec_helper'

RSpec.describe Clusters::KubernetesNamespaceFinder do
  let(:finder) do
    described_class.new(
      cluster,
      project: project,
      environment_slug: environment_slug,
      allow_blank_token: allow_blank_token
    )
  end

  def create_namespace(environment_slug, with_token: true)
    namespace = build(:cluster_kubernetes_namespace,
      (with_token ? :with_token : :without_token),
      cluster: cluster,
      project: project,
      environment_slug: environment_slug
    )

    namespace.set_defaults
    # If a namespace_per_environment is disabled the environment won't be included
    # in the default namespace, so to simulate records created under a different
    # namespace_per_environment setting we must add the environment manually.
    if environment_slug && !cluster.namespace_per_environment?
      namespace.namespace << "-#{environment_slug}"
    end

    namespace.tap(&:save!)
  end

  describe '#execute' do
    let(:cluster) { create(:cluster, :group, :provided_by_user) }
    let(:project) { create(:project) }
    let(:environment_slug) { 'production' }
    let(:allow_blank_token) { false }

    subject { finder.execute }

    before do
      allow(cluster).to receive(:namespace_per_environment?).and_return(namespace_per_environment)
    end

    context 'cluster supports separate namespaces per environment' do
      let(:namespace_per_environment) { true }

      context 'no persisted namespace is present' do
        it { is_expected.to be_nil }
      end

      context 'a legacy namespace with no environment is present' do
        let!(:legacy_namespace) { create_namespace(nil) }

        it { is_expected.to eq legacy_namespace }

        context 'a namespace with an environment is present' do
          context 'environment slug matches' do
            let!(:namespace_with_environment) { create_namespace(environment_slug) }

            it { is_expected.to eq namespace_with_environment }

            context 'project cluster' do
              let(:cluster) { create(:cluster, :project, :provided_by_user, projects: [project]) }

              it { is_expected.to eq namespace_with_environment }
            end

            context 'service account token is blank' do
              let!(:namespace_with_environment) { create_namespace(environment_slug, with_token: false) }

              it { is_expected.to eq legacy_namespace }

              context 'allow_blank_token is true' do
                let(:allow_blank_token) { true }

                it { is_expected.to eq namespace_with_environment }
              end
            end
          end

          context 'environment slug does not match' do
            let!(:namespace_with_environment) { create_namespace('staging') }

            it { is_expected.to eq legacy_namespace }
          end
        end
      end
    end

    context 'cluster does not support separate namespaces per environment' do
      let(:namespace_per_environment) { false }

      context 'no persisted namespace is present' do
        it { is_expected.to be_nil }
      end

      context 'a namespace with an environment is present' do
        let!(:namespace_with_environment) { create_namespace(environment_slug) }

        context 'environment slug matches' do
          let(:environment_slug) { 'production' }

          it { is_expected.to eq namespace_with_environment }

          context 'a legacy namespace with no environment is present' do
            let!(:legacy_namespace) { create_namespace(nil) }

            it { is_expected.to eq legacy_namespace }

            context 'project cluster' do
              let(:cluster) { create(:cluster, :project, :provided_by_user, projects: [project]) }

              it { is_expected.to eq legacy_namespace }
            end

            context 'service account token is blank' do
              let!(:legacy_namespace) { create_namespace(nil, with_token: false) }

              it { is_expected.to eq namespace_with_environment }

              context 'allow_blank_token is true' do
                let(:allow_blank_token) { true }

                it { is_expected.to eq legacy_namespace }
              end
            end
          end
        end

        context 'environment slug does not match' do
          let!(:namespace_with_environment) { create_namespace('staging') }

          it { is_expected.to be_nil }
        end
      end
    end
  end
end
