# frozen_string_literal: true

module Gitlab::UsageDataCounters
  class BasePageCounter
    extend RedisCounter

    UnknownEvent = Class.new(StandardError)

    class << self
      def redis_key(event)
        raise UnknownEvent, event unless self::KNOWN_EVENTS.include?(event.to_s)

        "USAGE_#{self::PAGE_TYPE}_PAGES_#{event}".upcase
      end

      def count(event)
        increment(redis_key event)
      end

      def read(event)
        total_count(redis_key event)
      end

      def totals
        self::KNOWN_EVENTS.map { |e| ["#{self::PAGE_TYPE}_pages_#{e}".to_sym, read(e)] }.to_h
      end
    end
  end
end
