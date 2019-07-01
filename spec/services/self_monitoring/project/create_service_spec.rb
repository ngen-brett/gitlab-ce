# frozen_string_literal: true

require 'spec_helper'

describe SelfMonitoring::Project::CreateService do
  describe '#execute' do
    context 'without admin users' do
      it 'raises error' do
        expect { subject.execute }.to raise_error(
          described_class::NoAdminUsersError,
          'No active admin user found'
        )
      end
    end

    context 'with admin users' do
      let!(:user) { create(:user, :admin) }
      let(:project) { subject.execute }

      it 'creates project with internal visibility' do
        expect(project.visibility_level).to eq(Gitlab::VisibilityLevel::INTERNAL)
        expect(project.persisted?).to eq(true)
      end

      it 'creates project with correct name and description' do
        expect(project.name).to eq(described_class::DEFAULT_NAME)
        expect(project.description).to eq(described_class::DEFAULT_DESCRIPTION)
      end

      it 'has prometheus service' do
        prometheus = project.prometheus_service

        expect(prometheus).not_to eq(nil)
        expect(prometheus.api_url).to eq('localhost:9090')
        expect(prometheus.active).to eq(true)
        expect(prometheus.manual_configuration).to eq(true)
      end

      it 'adds all admins as maintainers' do
        admin1 = create(:user, :admin)
        admin2 = create(:user, :admin)
        create(:user)

        expect(project.owner).to eq(user)
        expect(project.members.collect(&:user)).to contain_exactly(user, admin1, admin2)
        expect(project.members.collect(&:access_level)).to contain_exactly(
          Gitlab::Access::MAINTAINER,
          Gitlab::Access::MAINTAINER,
          Gitlab::Access::MAINTAINER
        )
      end

      context 'when prometheus setting is not present in gitlab.yml' do
        before do
          allow(Settings).to receive(:prometheus).and_raise(Settingslogic::MissingSetting)
        end

        it 'raises error' do
          expect { project }.to raise_error(
            described_class::NoPrometheusSettingInGitlabYml,
            'No prometheus setting in gitlab.yml'
          )
        end
      end
    end
  end
end
