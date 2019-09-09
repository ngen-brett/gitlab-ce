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
          when 'months';  3600 * hours_per_day * days_per_month
          when 'weeks';   3600 * hours_per_day * days_per_week
          when 'days';    3600 * hours_per_day
          else
            super
          end
        end

        # The only change: pass opts into `duration_units_seconds_multiplier`
        def calculate_from_words(string, opts)
          val = 0
          words = string.split(' ')
          words.each_with_index do |v, k|
            if v =~ float_matcher
              # Patch
              val += (convert_to_number(v) * duration_units_seconds_multiplier(words[k + 1] || (opts[:default_unit] || 'seconds'), opts))
              # End patch
            end
          end
          val
        end

        def output(seconds, opts = {})
          int = seconds.to_i
          seconds = int if seconds - int == 0 # if seconds end with .0

          opts[:format] ||= :default
          opts[:keep_zero] ||= false

          years = months = weeks = days = hours = minutes = 0

          decimal_places = seconds.to_s.split('.').last.length if seconds.is_a?(Float)

          # Patch
          hours_per_day = opts[:hours_per_day] || ::ChronicDuration.hours_per_day
          days_per_week = opts[:days_per_week] || ::ChronicDuration.days_per_week
          days_per_month = days_per_week == 7 ? 30 : days_per_week * 4
          # End patch

          minute = 60
          hour = 60 * minute
          # Patch
          day = hours_per_day * hour
          month = days_per_month * day # why it wasn't patched already since we re-defined days_per_week?
          # End patch
          year = 31557600

          if seconds >= 31557600 && seconds%year < seconds%month
            years = seconds / year
            months = seconds % year / month
            days = seconds % year % month / day
            hours = seconds % year % month % day / hour
            minutes = seconds % year % month % day % hour / minute
            seconds = seconds % year % month % day % hour % minute
          elsif seconds >= 60
            minutes = (seconds / 60).to_i
            seconds = seconds % 60
            if minutes >= 60
              hours = (minutes / 60).to_i
              minutes = (minutes % 60).to_i
              if !opts[:limit_to_hours]
                # Patch all ChronicDuration.hours_per_day and ChronicDuration.days_per_week
                if hours >= hours_per_day
                  days = (hours / hours_per_day).to_i
                  hours = (hours % hours_per_day).to_i
                  if opts[:weeks]
                    if days >= days_per_week
                      weeks = (days / days_per_week).to_i
                      days = (days % days_per_week).to_i
                # End patch
                      if weeks >= 4
                        months = (weeks / 4).to_i
                        weeks = (weeks % 4).to_i
                      end
                    end
                  else
                    # Patch `30` with days_per_month which could not always be `30`
                    if days >= days_per_month
                      months = (days / days_per_month).to_i
                      days = (days % days_per_month).to_i
                    end
                    # End patch
                  end
                end
              end
            end
          end

          joiner = opts.fetch(:joiner) { ' ' }
          process = nil

          case opts[:format]
          when :micro
            dividers = {
              :years => 'y', :months => 'mo', :weeks => 'w', :days => 'd', :hours => 'h', :minutes => 'm', :seconds => 's' }
            joiner = ''
          when :short
            dividers = {
              :years => 'y', :months => 'mo', :weeks => 'w', :days => 'd', :hours => 'h', :minutes => 'm', :seconds => 's' }
          when :default
            dividers = {
              :years => ' yr', :months => ' mo', :weeks => ' wk', :days => ' day', :hours => ' hr', :minutes => ' min', :seconds => ' sec',
              :pluralize => true }
          when :long
            dividers = {
              :years => ' year', :months => ' month', :weeks => ' week', :days => ' day', :hours => ' hour', :minutes => ' minute', :seconds => ' second',
              :pluralize => true }
          when :chrono
            dividers = {
              :years => ':', :months => ':', :weeks => ':', :days => ':', :hours => ':', :minutes => ':', :seconds => ':', :keep_zero => true }
            process = lambda do |str|
              # Pad zeros
              # Get rid of lead off times if they are zero
              # Get rid of lead off zero
              # Get rid of trailing :
              divider = ':'
              str.split(divider).map { |n|
                # add zeros only if n is an integer
                n.include?('.') ? ("%04.#{decimal_places}f" % n) : ("%02d" % n)
              }.join(divider).gsub(/^(00:)+/, '').gsub(/^0/, '').gsub(/:$/, '')
            end
            joiner = ''
          end

          result = [:years, :months, :weeks, :days, :hours, :minutes, :seconds].map do |t|
            next if t == :weeks && !opts[:weeks]
            num = eval(t.to_s)
            num = ("%.#{decimal_places}f" % num) if num.is_a?(Float) && t == :seconds
            keep_zero = dividers[:keep_zero]
            keep_zero ||= opts[:keep_zero] if t == :seconds
            humanize_time_unit( num, dividers[t], dividers[:pluralize], keep_zero )
          end.compact!

          result = result[0...opts[:units]] if opts[:units]

          result = result.join(joiner)

          if process
            result = process.call(result)
          end

          result.length == 0 ? nil : result

        end
      end
    end
  end
end
