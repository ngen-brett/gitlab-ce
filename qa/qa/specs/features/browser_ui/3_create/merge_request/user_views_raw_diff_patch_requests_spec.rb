# frozen_string_literal: true

module QA
  context 'Create' do
    # failure reported: https://gitlab.com/gitlab-org/quality/nightly/issues/42
    # also failing in staging until the fix is picked into the next release:
    #  https://gitlab.com/gitlab-org/gitlab-ce/merge_requests/24533
    describe 'Merge request data' do
      around do |example|
        QA::Runtime::Downloads.clear_downloads
        example.run
        QA::Runtime::Downloads.clear_downloads
      end

      before(:context) do
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.perform(&:sign_in_using_credentials)

        merge_request = Resource::MergeRequest.fabricate! do |merge_request|
          merge_request.title = 'Needs rebasing'
        end
      end

      it 'user views raw email patch' do
        Page::MergeRequest::Show.perform(&:select_email_patches)
        download_content = QA::Runtime::Downloads.download_content

        expect(download_content).to include("From: #{Runtime::User.name} <#{Runtime::User.email}>")
        expect(download_content).to have_text('Subject: [PATCH] This is a test commit')
        expect(download_content).to have_text('diff --git a/added_file.txt b/added_file.txt')
      end

      it 'user views raw commit diff' do
        Page::MergeRequest::Show.perform(&:select_plain_diff)
        download_content = QA::Runtime::Downloads.download_content

        expect(download_content).to start_with('diff --git a/second b/second')
        expect(download_content).to have_text('+second file content')
      end
    end
  end
end
