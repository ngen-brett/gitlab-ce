# frozen_string_literal: true

module Gitlab::UsageDataCounters
  class SnippetPageCounter < BasePageCounter
    KNOWN_EVENTS = %w[create update comment].map(&:freeze).freeze
    PAGE_TYPE = 'snippet'
  end
end
