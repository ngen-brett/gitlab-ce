# frozen_string_literal: true

FactoryBot.define do
  factory :error_tracking_setting, class: ErrorTracking::ErrorTrackingSetting do
    project
    enabled true
    uri 'http://error_tracking.url'
    token 'token'
  end
end
