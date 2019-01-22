require 'spec_helper'

describe ProjectAutoDevops do
  let(:project) { build(:project) }

  it_behaves_like 'having unique enum values'

  it { is_expected.to belong_to(:project) }

  it { is_expected.to define_enum_for(:deploy_strategy) }

  it { is_expected.to respond_to(:created_at) }
  it { is_expected.to respond_to(:updated_at) }

  describe '#has_domain?' do
    context 'when domain is defined' do
      let(:auto_devops) { build_stubbed(:project_auto_devops, project: project, domain: 'domain.com') }

      it { expect(auto_devops).to have_domain }
    end

    context 'when domain is empty' do
      let(:auto_devops) { build_stubbed(:project_auto_devops, project: project, domain: '') }

      context 'when there is an instance domain specified' do
        before do
          allow(Gitlab::CurrentSettings).to receive(:auto_devops_domain).and_return('example.com')
        end

        it { expect(auto_devops).to have_domain }
      end

      context 'when there is no instance domain specified' do
        before do
          allow(Gitlab::CurrentSettings).to receive(:auto_devops_domain).and_return(nil)
        end

        it { expect(auto_devops).not_to have_domain }
      end
    end
  end

  describe '#predefined_variables' do
    let(:auto_devops) { build_stubbed(:project_auto_devops, project: project, domain: domain) }

    context 'when domain is defined' do
      let(:domain) { 'example.com' }

      it 'returns AUTO_DEVOPS_DOMAIN' do
        expect(auto_devops.predefined_variables).to include(domain_variable)
      end

      describe "creates CI_PRODUCTION_ENVIRONMENT_URL variable" do
        let(:expected_ci_production_environment_url_var) do
          {
            key: 'CI_PRODUCTION_ENVIRONMENT_URL',
            value: "#{project.parent.path}-#{project.path}.#{domain}",
            public: true
          }
        end

        context 'production environment url > 64 bytes' do
          before do
            expected_ci_production_environment_url_var[:value] = "2228922881aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" \
                                                                 "-example-com"
            project.path = 'a' * 65
          end

          it 'returns a 64 bytes truncated version of CI_PRODUCTION_ENVIRONMENT_URL' do
            puts ">>>>>>>>>>>>> PROJECT FULL PATH: #{project.full_path_slug}"
            puts ">>>>>>>>>>>>> PROJECT FULL PATH: #{domain.presence || instance_domain}"
            expect(auto_devops.predefined_variables).to include(expected_ci_production_environment_url_var)
          end
        end

        context 'production environment url <= 64 bytes' do
          it 'returns a 64 bytes truncated version of CI_PRODUCTION_ENVIRONMENT_URL' do
            expect(auto_devops.predefined_variables).to include(expected_ci_production_environment_url_var)
          end
        end
      end

      describe "creates CI_STAGING_ENVIRONMENT_URL variable" do
        let(:expected_ci_staging_environment_url_var) do
          {
            key: 'CI_STAGING_ENVIRONMENT_URL',
            value: "#{project.parent.path}-#{project.path}-staging.#{domain}",
            public: true
          }
        end

        context 'staging environment url <= 64 bytes' do
          it 'returns a 64 bytes truncated version of CI_STAGING_ENVIRONMENT_URL' do
            expect(auto_devops.predefined_variables).to include(expected_ci_staging_environment_url_var)
          end
        end

        context 'staging environment url > 64 bytes' do
          before do
            expected_ci_staging_environment_url_var[:value] = "3312283892aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" \
                                                              "-staging-example-com"
            project.path = 'a' * 65
          end

          it 'returns a 64 bytes truncated version of CI_STAGING_ENVIRONMENT_URL' do
            puts ">>>>>>>>>>>>> PROJECT FULL PATH: #{project.full_path_slug}"
            puts ">>>>>>>>>>>>> PROJECT FULL PATH: #{domain.presence || instance_domain}"
            expect(auto_devops.predefined_variables).to include(expected_ci_staging_environment_url_var)
          end
        end
      end
    end

    context 'when domain is not defined' do
      let(:domain) { nil }

      context 'when there is an instance domain specified' do
        before do
          allow(Gitlab::CurrentSettings).to receive(:auto_devops_domain).and_return('example.com')
        end

        it { expect(auto_devops.predefined_variables).to include(domain_variable) }
      end

      context 'when there is no instance domain specified' do
        before do
          allow(Gitlab::CurrentSettings).to receive(:auto_devops_domain).and_return(nil)
        end

        it { expect(auto_devops.predefined_variables).not_to include(domain_variable) }
      end
    end

    context 'when deploy_strategy is manual' do
      let(:auto_devops) { build_stubbed(:project_auto_devops, :manual_deployment, project: project) }
      let(:expected_variables) do
        [
          { key: 'INCREMENTAL_ROLLOUT_MODE', value: 'manual' },
          { key: 'STAGING_ENABLED', value: '1' },
          { key: 'INCREMENTAL_ROLLOUT_ENABLED', value: '1' }
        ]
      end

      it { expect(auto_devops.predefined_variables).to include(*expected_variables) }
    end

    context 'when deploy_strategy is continuous' do
      let(:auto_devops) { build_stubbed(:project_auto_devops, :continuous_deployment, project: project) }

      it do
        expect(auto_devops.predefined_variables.map { |var| var[:key] })
          .not_to include("STAGING_ENABLED", "INCREMENTAL_ROLLOUT_ENABLED")
      end
    end

    context 'when deploy_strategy is timed_incremental' do
      let(:auto_devops) { build_stubbed(:project_auto_devops, :timed_incremental_deployment, project: project) }

      it { expect(auto_devops.predefined_variables).to include(key: 'INCREMENTAL_ROLLOUT_MODE', value: 'timed') }

      it do
        expect(auto_devops.predefined_variables.map { |var| var[:key] })
          .not_to include("STAGING_ENABLED", "INCREMENTAL_ROLLOUT_ENABLED")
      end
    end

    def domain_variable
      { key: 'AUTO_DEVOPS_DOMAIN', value: 'example.com', public: true }
    end
  end

  describe '#create_gitlab_deploy_token' do
    let(:auto_devops) { build(:project_auto_devops, project: project) }

    context 'when the project is public' do
      let(:project) { create(:project, :repository, :public) }

      it 'should not create a gitlab deploy token' do
        expect do
          auto_devops.save
        end.not_to change { DeployToken.count }
      end
    end

    context 'when the project is internal' do
      let(:project) { create(:project, :repository, :internal) }

      it 'should create a gitlab deploy token' do
        expect do
          auto_devops.save
        end.to change { DeployToken.count }.by(1)
      end
    end

    context 'when the project is private' do
      let(:project) { create(:project, :repository, :private) }

      it 'should create a gitlab deploy token' do
        expect do
          auto_devops.save
        end.to change { DeployToken.count }.by(1)
      end
    end

    context 'when autodevops is enabled at project level' do
      let(:project) { create(:project, :repository, :internal) }
      let(:auto_devops) { build(:project_auto_devops, project: project) }

      it 'should create a deploy token' do
        expect do
          auto_devops.save
        end.to change { DeployToken.count }.by(1)
      end
    end

    context 'when autodevops is enabled at instance level' do
      let(:project) { create(:project, :repository, :internal) }
      let(:auto_devops) { build(:project_auto_devops, enabled: nil, project: project) }

      it 'should create a deploy token' do
        allow(Gitlab::CurrentSettings).to receive(:auto_devops_enabled?).and_return(true)

        expect do
          auto_devops.save
        end.to change { DeployToken.count }.by(1)
      end
    end

    context 'when autodevops is disabled' do
      let(:project) { create(:project, :repository, :internal) }
      let(:auto_devops) { build(:project_auto_devops, :disabled, project: project) }

      it 'should not create a deploy token' do
        expect do
          auto_devops.save
        end.not_to change { DeployToken.count }
      end
    end

    context 'when the project already has an active gitlab-deploy-token' do
      let(:project) { create(:project, :repository, :internal) }
      let!(:deploy_token) { create(:deploy_token, :gitlab_deploy_token, projects: [project]) }
      let(:auto_devops) { build(:project_auto_devops, project: project) }

      it 'should not create a deploy token' do
        expect do
          auto_devops.save
        end.not_to change { DeployToken.count }
      end
    end

    context 'when the project already has a revoked gitlab-deploy-token' do
      let(:project) { create(:project, :repository, :internal) }
      let!(:deploy_token) { create(:deploy_token, :gitlab_deploy_token, :expired, projects: [project]) }
      let(:auto_devops) { build(:project_auto_devops, project: project) }

      it 'should not create a deploy token' do
        expect do
          auto_devops.save
        end.not_to change { DeployToken.count }
      end
    end
  end
end
