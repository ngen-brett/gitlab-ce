# frozen_string_literal: true

module Gitlab::UsageDataCounters
  class WikiPageCounter < BasePageCounter
    KNOWN_EVENTS = %w[create update delete].map(&:freeze).freeze
    PAGE_TYPE = 'wiki'
  end
end
