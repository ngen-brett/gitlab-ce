# frozen_string_literal: true

require_relative 'tracing/redis_tracing'
require_relative 'tracing/rails_tracing'

module Gitlab
  module Tracing
    @@configured = false

    def self.enabled?
      return true
    end

    def self.configured?
      return enabled? && @@configured
    end

    def self.configured=(value)
      @@configured = value
    end

  end
end

