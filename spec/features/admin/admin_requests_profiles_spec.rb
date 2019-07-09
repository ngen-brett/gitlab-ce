require 'spec_helper'

describe 'Admin::RequestsProfilesController' do
  before do
    FileUtils.mkdir_p(Gitlab::RequestProfiler::PROFILES_DIR)
    sign_in(create(:admin))
  end

  after do
    Gitlab::RequestProfiler.remove_all_profiles
  end

  describe 'GET /admin/requests_profiles' do
    it 'shows the current profile token' do
      allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)

      visit admin_requests_profiles_path

      expect(page).to have_content("X-Profile-Token: #{Gitlab::RequestProfiler.profile_token}")
    end

    it 'lists all available profiles' do
      time1 = 1.hour.ago
      time2 = 2.hours.ago
      time3 = 3.hours.ago
      time4 = 4.hours.ago
      time5 = 5.hours.ago
      time6 = 6.hours.ago
      profile1 = "|gitlab-org|gitlab-ce_#{time1.to_i}_execution.html"
      profile2 = "|gitlab-org|gitlab-ce_#{time2.to_i}_execution.html"
      profile3 = "|gitlab-com|infrastructure_#{time3.to_i}_execution.html"
      profile4 = "|gitlab-org|gitlab-ce_#{time4.to_i}_memory.txt"
      profile5 = "|gitlab-org|gitlab-ce_#{time5.to_i}_memory.txt"
      profile6 = "|gitlab-com|infrastructure_#{time6.to_i}_memory.txt"

      FileUtils.touch("#{Gitlab::RequestProfiler::PROFILES_DIR}/#{profile1}")
      FileUtils.touch("#{Gitlab::RequestProfiler::PROFILES_DIR}/#{profile2}")
      FileUtils.touch("#{Gitlab::RequestProfiler::PROFILES_DIR}/#{profile3}")
      FileUtils.touch("#{Gitlab::RequestProfiler::PROFILES_DIR}/#{profile4}")
      FileUtils.touch("#{Gitlab::RequestProfiler::PROFILES_DIR}/#{profile5}")
      FileUtils.touch("#{Gitlab::RequestProfiler::PROFILES_DIR}/#{profile6}")

      visit admin_requests_profiles_path

      within('.card', text: '/gitlab-org/gitlab-ce') do
        expect(page).to have_selector("a[href='#{admin_requests_profile_path(profile1)}']", text: time1.to_s(:long) + ' Execution')
        expect(page).to have_selector("a[href='#{admin_requests_profile_path(profile2)}']", text: time2.to_s(:long) + ' Execution')
        expect(page).to have_selector("a[href='#{admin_requests_profile_path(profile4)}']", text: time4.to_s(:long) + ' Memory')
        expect(page).to have_selector("a[href='#{admin_requests_profile_path(profile5)}']", text: time5.to_s(:long) + ' Memory')
      end

      within('.card', text: '/gitlab-com/infrastructure') do
        expect(page).to have_selector("a[href='#{admin_requests_profile_path(profile3)}']", text: time3.to_s(:long) + ' Execution')
        expect(page).to have_selector("a[href='#{admin_requests_profile_path(profile6)}']", text: time6.to_s(:long) + ' Memory')
      end
    end
  end

  describe 'GET /admin/requests_profiles/:profile' do
    context 'when a profile exists' do
      it 'displays the content of the call stack profile' do
        content = 'This is a call stack request profile'
        profile = "|gitlab-org|gitlab-ce_#{Time.now.to_i}_execution.html"

        File.write("#{Gitlab::RequestProfiler::PROFILES_DIR}/#{profile}", content)

        visit admin_requests_profile_path(profile)

        expect(page).to have_content(content)
      end

      it 'displays the content of the memory profile' do
        content = 'This is a memory request profile'
        profile = "|gitlab-org|gitlab-ce_#{Time.now.to_i}_memory.txt"

        File.write("#{Gitlab::RequestProfiler::PROFILES_DIR}/#{profile}", content)

        visit admin_requests_profile_path(profile)

        expect(page).to have_content(content)
      end
    end

    context 'when a profile does not exist' do
      it 'shows an error message' do
        visit admin_requests_profile_path('|non|existent_12345.html')

        expect(page).to have_content('Profile not found')
      end
    end
  end
end
