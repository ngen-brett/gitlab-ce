# frozen_string_literal: true

# Fixes a bug where parsing months doesn't take into account
# the ChronicDuration.days_per_week setting
#
# We can remove this when we do a refactor and push upstream in
# https://gitlab.com/gitlab-org/gitlab-ce/issues/66637

module Gitlab
  module Patch
    module ChronicDuration
      extend ActiveSupport::Concern

      class_methods do
        def duration_units_seconds_multiplier(unit, opts)
          # Take into account that custom definitions could be passed
          hours_per_day = opts[:hours_per_day] || ::ChronicDuration.hours_per_day
          days_per_week = opts[:days_per_week] || ::ChronicDuration.days_per_week

          # ChronicDuration#output uses 1mo = 4w as the conversion so we do the same here.
          # We do need to add a special case for the default days_per_week value because
          # we want to retain existing behavior for the default case
          days_per_month = days_per_week == 7 ? 30 : days_per_week * 4

          return 0 unless duration_units_list.include?(unit)
          case unit
          when 'years';   31557600
          when 'months';  3600 * hours_per_day * days_per_month
          when 'weeks';   3600 * hours_per_day * days_per_week
          when 'days';    3600 * hours_per_day
          when 'hours';   3600
          when 'minutes'; 60
          when 'seconds'; 1
          end
        end

        # The only change: pass opts into `duration_units_seconds_multiplier`
        def calculate_from_words(string, opts)
          val = 0
          words = string.split(' ')
          words.each_with_index do |v, k|
            if v =~ float_matcher
              val += (convert_to_number(v) * duration_units_seconds_multiplier(words[k + 1] || (opts[:default_unit] || 'seconds'), opts))
            end
          end
          val
        end
      end
    end
  end
end
