# frozen_string_literal: true

require 'spec_helper'

describe ErrorTracking::SentryIssuesService do
  let(:sentry_url) { 'https://sentrytest.gitlab.com/api/0/projects/sentry-org/sentry-project' }
  let(:token) { 'test-token' }
  subject(:service) { described_class.new(sentry_url, token) }

  describe '#execute' do
    before do
      # url = "http://35.228.54.90:9000/api/0/projects/sentry/sentry-example"
      # SENTRY_TOKEN = "e0a62611242e42c3b2ee3055245b6bc80313be84e66444fab7fa8fc9d2d5f722"

      resp = [{
        "lastSeen": "2018-12-31T12:00:11Z",
        "numComments": 0,
        "userCount": 0,
        "stats": {
            "24h": [
                [
                    1546437600,
                    0
                ]
            ]
        },
        "culprit": "sentry.tasks.reports.deliver_organization_user_report",
        "title": "gaierror: [Errno -2] Name or service not known",
        "id": "11",
        "assignedTo": nil,
        "logger": nil,
        "type": "error",
        "annotations": [],
        "metadata": {
            "type": "gaierror",
            "value": "[Errno -2] Name or service not known"
        },
        "status": "unresolved",
        "subscriptionDetails": nil,
        "isPublic": false,
        "hasSeen": false,
        "shortId": "INTERNAL-4",
        "shareId": nil,
        "firstSeen": "2018-12-17T12:00:14Z",
        "count": "21",
        "permalink": "35.228.54.90/sentry/internal/issues/11/",
        "level": "error",
        "isSubscribed": true,
        "isBookmarked": false,
        "project": {
            "slug": "internal",
            "id": "1",
            "name": "Internal"
        },
        "statusDetails": {}
      }]
    # {
    #     "lastSeen": "2018-12-17T12:00:27Z",
    #     "numComments": 0,
    #     "userCount": 0,
    #     "stats": {
    #         "24h": [
    #             [
    #                 1546437600,
    #                 0
    #             ]
    #         ]
    #     },
    #     "culprit": "sentry.tasks.email.send_email",
    #     "title": "gaierror: [Errno -2] Name or service not known",
    #     "id": "1",
    #     "assignedTo": nil,
    #     "logger": nil,
    #     "type": "error",
    #     "annotations": [],
    #     "metadata": {
    #         "type": "gaierror",
    #         "value": "[Errno -2] Name or service not known"
    #     },
    #     "status": "unresolved",
    #     "subscriptionDetails": nil,
    #     "isPublic": false,
    #     "hasSeen": true,
    #     "shortId": "INTERNAL-1",
    #     "shareId": nil,
    #     "firstSeen": "2018-12-11T10:54:35Z",
    #     "count": "84",
    #     "permalink": "35.228.54.90/sentry/internal/issues/1/",
    #     "level": "error",
    #     "isSubscribed": true,
    #     "isBookmarked": false,
    #     "project": {
    #         "slug": "internal",
    #         "id": "1",
    #         "name": "Internal"
    #     },
    #     "statusDetails": {}
    # },
    # {
    #     "lastSeen": "2018-12-16T12:33:14Z",
    #     "numComments": 0,
    #     "userCount": 1,
    #     "stats": {
    #         "24h": [
    #             [
    #                 1546437600,
    #                 0
    #             ]
    #         ]
    #     },
    #     "culprit": "sentry.wsgi in __call__",
    #     "title": "KeyError: u'REQUEST_METHOD'",
    #     "id": "9",
    #     "assignedTo": nil,
    #     "logger": nil,
    #     "type": "error",
    #     "annotations": [],
    #     "metadata": {
    #         "type": "KeyError",
    #         "value": "u'REQUEST_METHOD'"
    #     },
    #     "status": "unresolved",
    #     "subscriptionDetails": nil,
    #     "isPublic": false,
    #     "hasSeen": false,
    #     "shortId": "INTERNAL-2",
    #     "shareId": nil,
    #     "firstSeen": "2018-12-16T12:33:14Z",
    #     "count": "1",
    #     "permalink": "35.228.54.90/sentry/internal/issues/9/",
    #     "level": "fatal",
    #     "isSubscribed": true,
    #     "isBookmarked": false,
    #     "project": {
    #         "slug": "internal",
    #         "id": "1",
    #         "name": "Internal"
    #     },
    #     "statusDetails": {}
    # },
    # {
    #     "lastSeen": "2018-12-16T12:33:14Z",
    #     "numComments": 0,
    #     "userCount": 1,
    #     "stats": {
    #         "24h": [
    #             [
    #                 1546437600,
    #                 0
    #             ]
    #         ]
    #     },
    #     "culprit": "sentry.wsgi in __call__",
    #     "title": "KeyError: u'REQUEST_METHOD'",
    #     "id": "10",
    #     "assignedTo": nil,
    #     "logger": nil,
    #     "type": "error",
    #     "annotations": [],
    #     "metadata": {
    #         "type": "KeyError",
    #         "value": "u'REQUEST_METHOD'"
    #     },
    #     "status": "unresolved",
    #     "subscriptionDetails": nil,
    #     "isPublic": false,
    #     "hasSeen": false,
    #     "shortId": "INTERNAL-3",
    #     "shareId": nil,
    #     "firstSeen": "2018-12-16T12:33:14Z",
    #     "count": "1",
    #     "permalink": "35.228.54.90/sentry/internal/issues/10/",
    #     "level": "error",
    #     "isSubscribed": true,
    #     "isBookmarked": false,
    #     "project": {
    #         "slug": "internal",
    #         "id": "1",
    #         "name": "Internal"
    #     },
    #     "statusDetails": {}
    # }]

      stub_sentry_request(sentry_url + '/issues/?limit=20&query=is:unresolved', body: resp)
    end

    it 'returns objects of type ErrorTracking::Error' do
      resp = service.execute
      expect(resp.length).to eq(1)
      expect(resp[0]).to be_a(ErrorTracking::Error)
    end
  end

  describe '#external_url' do
    it 'returns the correct url' do
      expect(service.external_url).to eq('https://sentrytest.gitlab.com/sentry-org/sentry-project')
    end
  end

  context 'redirects' do
    let(:redirect_to) { 'https://redirected.example.com' }
    let(:other_url) { 'https://other.example.org' }

    it 'does not follow redirects' do
      redirect_req_stub = stub_sentry_request(
        sentry_url + '/issues/?limit=20&query=is:unresolved',
        status: 302,
        headers: { location: redirect_to }
      )

      redirected_req_stub = stub_sentry_request(other_url)

      expect { service.execute }.to raise_exception(ErrorTracking::SentryIssuesService::Error, 'Sentry response error: 302')

      expect(redirect_req_stub).to have_been_requested
      expect(redirected_req_stub).not_to have_been_requested
    end
  end

  private

  def stub_sentry_request(url, body: {}, status: 200, headers: {})
    WebMock.stub_request(:get, url)
      .to_return({
        status: status,
        headers: { 'Content-Type' => 'application/json' }.merge(headers),
        body: body.to_json
      })
  end
end
