# frozen_string_literal: true

require 'rails_helper'

# These are written as feature specs because they cover more specific test scenarios
# than the ones described on spec/services/notes/create_service_spec.rb for quick actions,
# for example, adding quick actions when creating the issue and checking DateTime formats on UI.
# Because this kind of spec takes more time to run there is no need to add new ones
# for each existing quick action unless they test something not tested by existing tests.
describe 'Issues > User uses quick actions', :js do
  include Spec::Support::Helpers::Features::NotesHelpers

  context "issuable common quick actions" do
    let(:new_url_opts) { {} }
    let(:maintainer) { create(:user) }
    let(:project) { create(:project, :public) }
    let!(:label_bug) { create(:label, project: project, title: 'bug') }
    let!(:label_feature) { create(:label, project: project, title: 'feature') }
    let!(:milestone) { create(:milestone, project: project, title: 'ASAP') }
    let(:issuable) { create(:issue, project: project) }
    let(:source_issuable) { create(:issue, project: project, milestone: milestone, labels: [label_bug, label_feature])}

    it_behaves_like 'close quick action', :issue
    it_behaves_like 'issuable time tracker', :issue
  end

  describe 'issue-only commands' do
    let(:user) { create(:user) }
    let(:project) { create(:project, :public, :repository) }
    let(:issue) { create(:issue, project: project, due_date: Date.new(2016, 8, 28)) }

    before do
      project.add_maintainer(user)
      sign_in(user)
      visit project_issue_path(project, issue)
      wait_for_all_requests
    end

    after do
      wait_for_requests
    end

    it_behaves_like 'create_merge_request quick action'
    it_behaves_like 'move quick action'

    context 'move the issue to another project' do
      let(:target_project) { create(:project, :public) }

      context 'when the project is valid' do
        before do
          target_project.add_maintainer(user)
        end

        it 'moves the issue after quickcommand note was updated' do
          # missspelled quick action
          add_note("/mvoe #{target_project.full_path}")

          expect(page).not_to have_content 'Commands applied'
          expect(issue.reload).not_to be_closed

          edit_note("/mvoe #{target_project.full_path}", "/move #{target_project.full_path}")

          expect(page).to have_content 'Commands applied'
          expect(issue.reload).to be_closed

          visit project_issue_path(target_project, issue)

          expect(page).to have_content 'Issues 1'
        end
      end
    end
  end
end
