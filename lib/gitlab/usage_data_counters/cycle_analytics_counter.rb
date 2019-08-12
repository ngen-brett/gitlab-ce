module Gitlab::UsageDataCounters
  class CycleAnalyticsCounter < BaseCounter
    KNOWN_EVENTS = %w[views].freeze
    PREFIX = 'cylce_analytics'
  end
end

