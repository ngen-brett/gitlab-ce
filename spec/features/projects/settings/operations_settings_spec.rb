require 'spec_helper'

describe 'Projects > Settings > For a forked project', :js do
  let(:user) { create(:user) }
  let(:project) { create(:project, :repository) }
  let(:role) { :maintainer }

  before do
    stub_feature_flags(error_tracking: true)
    sign_in(user)
    project.add_role(user, role)
  end

  describe 'Sidebar > Operations' do

    context 'when sidebar feature flag enabled' do
      it 'renders the settings link in the sidebar' do
        visit project_path(project)
        wait_for_requests

        page.within '.nav-sidebar' do
          expect(page).to have_content ('Operations')
        end
      end
    end

    # TODO: Complete this test
    # context 'when sidebar feature flag disabled' do
    #   before do
    #     stub_feature_flags(error_tracking: false)
    #   end

    #   it 'does not render the settings link in the sidebar' do
    #     visit project_path(project)
    #     wait_for_requests

    #     find.find('qa-settings-item').find(:xpath, 'ancestor:')
    #     page.within('.sidebar-sub-level-items', text:'Settings') do
    #       expect(page).not_to have_content('Operations')
    #     end
    #   end
    # end
  end
end
