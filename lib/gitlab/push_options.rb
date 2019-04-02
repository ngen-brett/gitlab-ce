# frozen_string_literal: true

class Gitlab::PushOptions
  VALID_OPTIONS = {
    merge_request: {
      keys: [:create, :merge_when_pipeline_succeeds, :target]
    },
    ci: {
      keys: [:skip]
    }
  }.freeze

  NAMESPACE_ALIASES = {
    mr: :merge_request
  }.freeze

  OPTION_MATCHER = /(?<namespace>[^\.]+)\.(?<key>[^=]+)=?(?<value>.*)/

  attr_reader :options

  def initialize(options = [])
    @options = parse_options(options)
  end

  def get(*args)
    options.dig(*args)
  end

  def to_h
    options
  end

  private

  def parse_options(raw_options)
    options = {}

    Array.wrap(raw_options).each do |option|
      parts = OPTION_MATCHER.match(option)
      next unless parts

      namespace, key, value = parts.values_at(:namespace, :key, :value)

      namespace = namespace.strip.to_sym
      key = key.strip.to_sym
      value = value.strip.presence || true

      next if namespace.blank? || key.blank?

      namespace = NAMESPACE_ALIASES[namespace] if NAMESPACE_ALIASES[namespace]
      next unless valid_option?(namespace, key)

      options[namespace] ||= {}
      options[namespace][key] = value
    end

    options
  end

  def valid_option?(namespace, key)
    keys = VALID_OPTIONS.dig(namespace, :keys)
    keys && keys.include?(key)
  end
end
