require 'spec_helper'

describe API::ProjectTraffics do
  let(:developer) { create(:user) }
  let(:public_project) { create(:project, :public, namespace: developer.namespace) }

  describe 'GET /projects/:id/traffic/fetches' do
    let!(:fetch_statistics1) { create(:project_fetch_statistic, project: public_project, count: 30, date: 29.days.ago) }
    let!(:fetch_statistics2) { create(:project_fetch_statistic, project: public_project, count: 4, date: 3.days.ago) }
    let!(:fetch_statistics3) { create(:project_fetch_statistic, project: public_project, count: 3, date: 2.days.ago) }
    let!(:fetch_statistics4) { create(:project_fetch_statistic, project: public_project, count: 2, date: 1.day.ago) }
    let!(:fetch_statistics5) { create(:project_fetch_statistic, project: public_project, count: 1, date: Date.today) }
    let!(:fetch_statistics_other_project) { create(:project_fetch_statistic, project: create(:project), count: 29, date:  29.days.ago) }

    it 'returns the fetch statistics of the last 30 days' do
      get api("/projects/#{public_project.id}/traffic/fetches", developer)

      expect(response).to have_gitlab_http_status(200)
      expect(json_response['count']).to eq(40)
      expect(json_response['fetches'].length).to eq(5)
      expect(json_response['fetches'].first).to eq({'count' => fetch_statistics5.count, 'date' => fetch_statistics5.date.to_s})
      expect(json_response['fetches'].last).to eq({'count' => fetch_statistics1.count, 'date' => fetch_statistics1.date.to_s})
    end

    it 'excludes the fetch statistics older than 30 days' do
      create(:project_fetch_statistic, count: 31, project: public_project, date: 30.days.ago)

      get api("/projects/#{public_project.id}/traffic/fetches", developer)

      expect(response).to have_gitlab_http_status(200)
      expect(json_response['count']).to eq(40)
      expect(json_response['fetches'].length).to eq(5)
      expect(json_response['fetches'].last).to eq({'count' => fetch_statistics1.count, 'date' => fetch_statistics1.date.to_s})
    end

    it "responds with 403 when the user dosn't have write access to the repository" do
      get api("/projects/#{public_project.id}/traffic/fetches", create(:user))

      expect(response).to have_gitlab_http_status(403)
      expect(json_response['message']).to eq('403 Forbidden')
    end
  end
end
