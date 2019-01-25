# frozen_string_literal: true

require 'spec_helper'

describe ErrorTracking::ProjectErrorTrackingSetting do
  include ReactiveCachingHelpers

  set(:project) { create(:project) }

  subject { create(:project_error_tracking_setting, project: project) }

  describe 'Associations' do
    it { is_expected.to belong_to(:project) }
  end

  describe 'Validations' do
    context 'when api_url is over 255 chars' do
      before do
        subject.api_url = 'https://' + 'a' * 250
      end

      it 'fails validation when enabled' do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:api_url]).to include('is too long (maximum is 255 characters)')
      end

      it 'passes validation when disabled' do
        subject.enabled = false

        expect(subject).to be_valid
      end
    end

    context 'With unsafe url' do
      it 'fails validation' do
        subject.api_url = "https://replaceme.com/'><script>alert(document.cookie)</script>"

        expect(subject).not_to be_valid
      end
    end

    context 'when token missing' do
      it 'fails validation when enabled' do
        subject.token = nil

        expect(subject).not_to be_valid
      end

      it 'passes validation when disabled' do
        subject.token = nil
        subject.enabled = false

        expect(subject).to be_valid
      end
    end

    context 'when api_url missing' do
      it 'fails validation when enabled' do
        subject.api_url = nil

        expect(subject).not_to be_valid
      end

      it 'passes validation when disabled' do
        subject.api_url = nil
        subject.enabled = false

        expect(subject).to be_valid
      end
    end

    context 'URL path' do
      it 'fails validation with wrong path' do
        subject.api_url = 'http://gitlab.com/project1/something'

        expect(subject).not_to be_valid
        expect(subject.errors.messages[:api_url]).to include('path needs to start with /api/0/projects')
      end

      it 'passes validation with correct path' do
        subject.api_url = 'http://gitlab.com/api/0/projects/project1/something'

        expect(subject).to be_valid
      end
    end
  end

  describe '#sentry_external_url' do
    let(:sentry_url) { 'https://sentrytest.gitlab.com/api/0/projects/sentry-org/sentry-project' }

    before do
      subject.api_url = sentry_url
    end

    it 'returns the correct url' do
      expect(subject.class).to receive(:extract_sentry_external_url).with(sentry_url).and_call_original

      result = subject.sentry_external_url

      expect(result).to eq('https://sentrytest.gitlab.com/sentry-org/sentry-project')
    end
  end

  describe '#sentry_client' do
    it 'returns sentry client' do
      expect(subject.sentry_client).to be_a(Sentry::Client)
    end
  end

  describe '#list_sentry_issues' do
    let(:issues) { [:list, :of, :issues] }

    let(:opts) do
      { issue_status: 'unresolved', limit: 10 }
    end

    let(:result) do
      subject.list_sentry_issues(**opts)
    end

    context 'when cached' do
      let(:sentry_client) { spy(:sentry_client) }

      before do
        stub_reactive_cache(subject, issues, opts)
        synchronous_reactive_cache(subject)

        expect(subject).to receive(:sentry_client).and_return(sentry_client)
      end

      it 'returns cached issues' do
        expect(sentry_client).to receive(:list_issues).with(opts)
          .and_return(issues)

        expect(result).to eq(issues: issues)
      end
    end

    context 'when not cached' do
      it 'returns nil' do
        expect(subject).not_to receive(:sentry_client)

        expect(result).to be_nil
      end
    end
  end

  describe '#list_sentry_projects' do
    let(:projects) { [:list, :of, :projects] }

    let(:result) do
      subject.list_sentry_projects
    end

    context 'when cached' do
      let(:sentry_client) { spy(:sentry_client) }

      before do
        stub_reactive_cache(subject, projects, {})
        synchronous_reactive_cache(subject)

        expect(subject).to receive(:sentry_client).and_return(sentry_client)
      end

      it 'returns cached projects' do
        expect(sentry_client).to receive(:list_projects)
          .and_return(projects)

        expect(result).to eq(projects: projects)
      end
    end

    context 'when not cached' do
      it 'returns nil' do
        expect(subject).not_to receive(:sentry_client)

        expect(result).to be_nil
      end
    end
  end

  describe '#project_slug' do
    it 'returns slug when api_url is correct' do
      subject.api_url = 'http://gitlab.com/api/0/projects/org-slug/project-slug'

      expect(subject.project_slug).to eq('project-slug')
    end

    it 'returns nil when api_url is blank' do
      subject.api_url = nil

      expect(subject.project_slug).to be_nil
    end
  end

  describe '#organization_slug' do
    it 'returns slug when api_url is correct' do
      subject.api_url = 'http://gitlab.com/api/0/projects/org-slug/project-slug'

      expect(subject.organization_slug).to eq('org-slug')
    end

    it 'returns nil when api_url is blank' do
      subject.api_url = nil

      expect(subject.organization_slug).to be_nil
    end
  end

  describe '.build_api_url_from' do
    it 'correctly builds api_url with slugs' do
      api_url = described_class.build_api_url_from(
        api_host: 'http://sentry.com/',
        organization_slug: 'org-slug',
        project_slug: 'proj-slug'
      )

      expect(api_url).to eq('http://sentry.com/api/0/projects/org-slug/proj-slug/')
    end

    it 'correctly builds api_url without slugs' do
      api_url = described_class.build_api_url_from(
        api_host: 'http://sentry.com/',
        organization_slug: nil,
        project_slug: nil
      )

      expect(api_url).to eq('http://sentry.com/api/0/projects/')
    end
  end
end
