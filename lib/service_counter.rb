# frozen_string_literal: true

module ServiceCounter
  extend ActiveSupport::Concern
  extend Gitlab::UsageDataCounters::RedisCounter
  include Gitlab::Utils::StrongMemoize

  def usage_log
    keys = Array(self.class.usage_key)
    keys.prepend('usage_count')

    self.class.increment(keys.join('/')) # in the future we will also pass user_id to enable SMAU
  end

  class_methods do
    def usage_total_count
      total_count(usage_key)
    end

    def usage_key
      strong_memoize(:usage_key) do
        name.underscore.gsub(/_service$/, '')
      end
    end
  end
end
