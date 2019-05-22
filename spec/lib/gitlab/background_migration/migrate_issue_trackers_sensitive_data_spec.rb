# frozen_string_literal: true
require 'spec_helper'

describe Gitlab::BackgroundMigration::MigrateIssueTrackersSensitiveData, :migration, schema: 20190521152847 do
  let(:services) { table(:services) }

  # [{:type=>"JiraService",
  #   :properties=>
  #     {"api_url"=>"http://api.jira.com",
  #      "jira_issue_transition_id"=>"56",
  #      "password"=>"jirapassword",
  #      "url"=>"http://web.jira.com",
  #      "username"=>"jirauser"}},
  #  {:type=>"BugzillaService",
  #   :properties=>
  #     {"description"=>"Bugzilla issue tracker",
  #      "issues_url"=>"http://issues.bugzilla.com",
  #      "new_issue_url"=>"http://new-issue.bugzilla.com",
  #      "project_url"=>"http://project.bugzilla.com"}},
  #  {:type=>"YoutrackService",
  #   :properties=>
  #     {"description"=>"YouTrack issue tracker",
  #      "issues_url"=>"http://issues.youtrack.com",
  #      "project_url"=>"http://project.youtrack.com"}},
  #  {:type=>"RedmineService",
  #   :properties=>
  #     {"description"=>"Redmine issue tracker",
  #      "issues_url"=>"http://issues.redmine.com",
  #      "new_issue_url"=>"http://new-issue.redmine.com",
  #      "project_url"=>"http://project.redmine.com"}},
  #  {:type=>"CustomIssueTrackerService",
  #   :properties=>
  #     {"description"=>"Custom issue tracker",
  #      "issues_url"=>"http://issues.custom.com",
  #      "new_issue_url"=>"http://new-issue.custom.com",
  #      "project_url"=>"http://project.custom.com",
  #      "title"=>"Custom Issue Tracker"}}]

  # Api-url: Jira,
  # jira_issue_transition_id: Jira
  # password: Jira
  # username: Jira
  # url: Jira
  # issues_url: BugzillaService, YoutrackService, RedmineService, CustomIssueTrackerService
  # new_issue_url: BugzillaService, YoutrackService, CustomIssueTrackerService
  # project_url: BugzillaService, YoutrackService, RedmineService, CustomIssueTrackerService

  let(:url) { 'http://base-url.tracker.com' }
  let(:issues_url) { 'http://issues-url.tracker.com' }
  let(:new_issue_url) { 'http://issue-new.tracker.com' }
  let(:api_url) { 'http://api.tracker.com' }
  let(:password) { 'passw1234' }
  let(:username) { 'user9' }
  let(:jira_properties) do
    {
      'api_url' => api_url,
      'jira_issue_transition_id' => '5',
      'password' => password,
      'url' => url,
      'username' => username
    }
  end
  let(:bugzilla_properties) do
    {
      'project_url' => url,
      'issues_url' => issues_url,
      'new_issue_url' => new_issue_url
    }
  end
  let(:redmine_properties) do
    {
      'project_url' => api_url,
      'issues_url' => issues_url,
      'new_issue_url' => new_issue_url
    }
  end
  let!(:jira_service) do
    services.create(type: 'JiraService', properties: jira_properties.to_json)
  end
  let!(:bugzilla_service) do
    services.create(type: 'BugzillaService', properties: bugzilla_properties.to_json)
  end
  let!(:redmine_service) do
    services.create(type: 'RedmineService', properties: redmine_properties.to_json)
  end

  before do
    described_class.new.perform
  end

  it 'keeps properties in services table' do
    expect(JSON.parse(jira_service.properties)).to eq(jira_properties)
  end

  it 'migrates data correctly for all issue trackers' do
    # we need to use the class because of fields encryption
    data = described_class::JiraTrackerData.find_by(service_id: jira_service.id)

    expect(data.url).to eq(url)
    expect(data.api_url).to eq(api_url)
    expect(data.username).to eq(username)
    expect(data.password).to eq(password)
    expect(data.jira_issue_transition_id).to eq('5')

    data = described_class::IssueTrackerData.find_by(service_id: bugzilla_service.id)

    expect(data.project_url).to eq(url)
    expect(data.issues_url).to eq(issues_url)
    expect(data.new_issue_url).to eq(new_issue_url)

    data = described_class::IssueTrackerData.find_by(service_id: redmine_service.id)

    expect(data.project_url).to eq(api_url)
    expect(data.issues_url).to eq(issues_url)
    expect(data.new_issue_url).to eq(new_issue_url)
  end
end
