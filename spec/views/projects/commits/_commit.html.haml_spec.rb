require 'spec_helper'

describe 'projects/commits/_commit.html.haml' do
  before do
    allow(view).to receive(:current_application_settings).and_return(Gitlab::CurrentSettings.current_application_settings)
  end

  context 'with a signed commit' do
    let(:project) { create(:project, :repository) }
    let(:repository) { project.repository }
    let(:ref) { GpgHelpers::SIGNED_COMMIT_SHA }
    let(:commit) { repository.commit(ref) }

    it 'does not display a loading spinner for GPG status' do
      render partial: 'projects/commits/commit', locals: {
        project: project,
        ref: ref,
        commit: commit
      }

      within '.gpg-status-box' do
        expect(page).not_to have_css('i.fa.fa-spinner.fa-spin')
      end
    end
  end

  context 'with ci status' do
    let(:project) { create(:project, :repository) }
    let(:repository) { project.repository }
    let(:commit) { repository.commit('master') }
    let(:user) { create(:user) }

    it 'does not display a ci status icon when pipelines are disabled' do
      allow(project).to receive(:builds_enabled?).and_return(false)
      allow(view).to receive(:current_user).and_return(user)
      project.add_developer(user)
      create(
        :ci_empty_pipeline,
        ref: 'master',
        sha: commit.id,
        status: 'success',
        project: project
      )

      render partial: 'projects/commits/commit', locals: {
        project: project,
        ref: 'master',
        commit: commit
      }

      expect(rendered).not_to have_css('.ci-status-link')
    end

    it 'does display a ci status icon when pipelines are enabled' do
      allow(project).to receive(:builds_enabled?).and_return(true)
      allow(view).to receive(:current_user).and_return(user)
      project.add_developer(user)
      create(
        :ci_empty_pipeline,
        ref: 'master',
        sha: commit.id,
        status: 'success',
        project: project
      )

      render partial: 'projects/commits/commit', locals: {
        project: project,
        ref: 'master',
        commit: commit
      }

      expect(rendered).to have_css('.ci-status-link')
    end
  end
end
