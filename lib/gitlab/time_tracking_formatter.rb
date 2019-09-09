# frozen_string_literal: true

module Gitlab
  module TimeTrackingFormatter
    extend self

    # We may want to configure it through project settings in a future version.
    CUSTOM_DAY_AND_WEEK_LENGTH = { hours_per_day: 8, days_per_week: 5 }.freeze

    def parse(string)
      string = string.sub(/\A-/, '')

      seconds = ChronicDuration.parse(string, default_unit: 'hours', **CUSTOM_DAY_AND_WEEK_LENGTH) rescue nil
      seconds *= -1 if seconds && Regexp.last_match
      seconds
    end

    def output(seconds)
      ChronicDuration.output(seconds, format: :short, limit_to_hours: limit_to_hours_setting, weeks: true, **CUSTOM_DAY_AND_WEEK_LENGTH) rescue nil
    end

    private

    def limit_to_hours_setting
      Gitlab::CurrentSettings.time_tracking_limit_to_hours
    end
  end
end
