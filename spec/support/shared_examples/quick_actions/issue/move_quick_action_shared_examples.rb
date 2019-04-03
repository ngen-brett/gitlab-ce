# frozen_string_literal: true

shared_examples 'move quick action' do
  context 'move the issue to another project' do
    let(:issue) { create(:issue, project: project) }

    context 'when the project is valid' do
      let(:target_project) { create(:project, :public) }

      before do
        target_project.add_maintainer(user)
        gitlab_sign_out
        sign_in(user)
        visit project_issue_path(project, issue)
        wait_for_requests
      end

      it 'moves the issue' do
        add_note("/move #{target_project.full_path}")

        expect(page).to have_content 'Commands applied'
        expect(issue.reload).to be_closed

        visit project_issue_path(target_project, issue)

        expect(page).to have_content 'Issues 1'
      end
    end

    context 'when the project is valid but the user not authorized' do
      let(:project_unauthorized) { create(:project, :public) }

      before do
        gitlab_sign_out
        sign_in(user)
        visit project_issue_path(project, issue)
        wait_for_requests
      end

      it 'does not move the issue' do
        add_note("/move #{project_unauthorized.full_path}")

        wait_for_requests

        expect(page).to have_content 'Commands applied'
        expect(issue.reload).to be_open
      end
    end

    context 'when the project is invalid' do
      before do
        gitlab_sign_out
        sign_in(user)
        visit project_issue_path(project, issue)
        wait_for_requests
      end

      it 'does not move the issue' do
        add_note("/move not/valid")

        wait_for_requests

        expect(page).to have_content 'Commands applied'
        expect(issue.reload).to be_open
      end
    end

    context 'when the user issues multiple commands' do
      let(:target_project) { create(:project, :public) }
      let(:milestone) { create(:milestone, title: '1.0', project: project) }
      let(:target_milestone) { create(:milestone, title: '1.0', project: target_project) }
      let(:bug)      { create(:label, project: project, title: 'bug') }
      let(:wontfix)  { create(:label, project: project, title: 'wontfix') }
      let(:bug_target)      { create(:label, project: target_project, title: 'bug') }
      let(:wontfix_target)  { create(:label, project: target_project, title: 'wontfix') }

      before do
        target_project.add_maintainer(user)
        gitlab_sign_out
        sign_in(user)
        visit project_issue_path(project, issue)
      end

      it 'applies the commands to both issues and moves the issue' do
        add_note("/label ~#{bug.title} ~#{wontfix.title}\n\n/milestone %\"#{milestone.title}\"\n\n/move #{target_project.full_path}")

        expect(page).to have_content 'Commands applied'
        expect(issue.reload).to be_closed

        visit project_issue_path(target_project, issue)

        expect(page).to have_content 'bug'
        expect(page).to have_content 'wontfix'
        expect(page).to have_content '1.0'

        visit project_issue_path(project, issue)
        expect(page).to have_content 'Closed'
        expect(page).to have_content 'bug'
        expect(page).to have_content 'wontfix'
        expect(page).to have_content '1.0'
      end

      it 'moves the issue and applies the commands to both issues' do
        add_note("/move #{target_project.full_path}\n\n/label ~#{bug.title} ~#{wontfix.title}\n\n/milestone %\"#{milestone.title}\"")

        expect(page).to have_content 'Commands applied'
        expect(issue.reload).to be_closed

        visit project_issue_path(target_project, issue)

        expect(page).to have_content 'bug'
        expect(page).to have_content 'wontfix'
        expect(page).to have_content '1.0'

        visit project_issue_path(project, issue)
        expect(page).to have_content 'Closed'
        expect(page).to have_content 'bug'
        expect(page).to have_content 'wontfix'
        expect(page).to have_content '1.0'
      end
    end
  end
end
