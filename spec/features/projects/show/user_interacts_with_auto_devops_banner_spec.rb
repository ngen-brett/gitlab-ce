# frozen_string_literal: true

require 'spec_helper'

describe 'Project > Show > User interacts with Auto DevOps implicitly enabled banner' do
  let(:project) { create(:project, :repository) }
  let(:user) { create(:user) }

  before do
    project.add_user(user, role)
    sign_in(user)
  end

  context 'when user does not have maintainer access' do
    let(:role) { :developer }

    it 'does not display AutoDevOps implicitly enabled banner' do
      expect(page).not_to have_css('.auto-devops-implicitly-enabled-banner')
    end
  end

  context 'when user has mantainer access' do
    let(:role) { :maintainer }
    let(:builds_visibility) { ProjectFeature::ENABLED }

    context 'when AutoDevOps is implicitly enabled' do
      before do
        stub_application_setting(auto_devops_enabled: true)
        project.project_feature.update_attribute(:builds_access_level, builds_visibility)

        visit project_path(project)
      end

      it 'display AutoDevOps implicitly enabled banner' do
        expect(page).to have_css('.auto-devops-implicitly-enabled-banner')
      end

      it 'displays a Settings link' do
        page.within('.auto-devops-implicitly-enabled-banner') do
          expect(page).to have_link('Settings')
        end
      end

      context 'when user dismisses the banner', :js do
        it 'does not display AutoDevOps implicitly enabled banner' do
          find('.hide-auto-devops-implicitly-enabled-banner').click
          wait_for_requests
          visit project_path(project)

          expect(page).not_to have_css('.auto-devops-implicitly-enabled-banner')
        end
      end

      context 'when project has builds disabled' do
        let(:builds_visibility) { ProjectFeature::DISABLED }

        it 'should not display More Information link' do
          page.within('.auto-devops-implicitly-enabled-banner') do
            expect(page).not_to have_link('Settings')
          end
        end
      end
    end

    context 'when AutoDevOps is not implicitly enabled' do
      before do
        stub_application_setting(auto_devops_enabled: false)

        visit project_path(project)
      end

      it 'does not display AutoDevOps implicitly enabled banner' do
        expect(page).not_to have_css('.auto-devops-implicitly-enabled-banner')
      end
    end
  end
end
