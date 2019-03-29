# frozen_string_literal: true

class Gitlab::PushOptions
  NAMESPACES = [:merge_request].freeze
  NAMESPACE_ALIASES = {
    mr: :merge_request
  }.freeze

  REGEX_MATCHER = /(?<namespace>[^\.]+)\.(?<key>[^=]+)=?(?<value>.*)/

  attr_reader :options

  def initialize(options = [])
    @options = parse_options(options)
  end

  def get(*args)
    options.dig(*args)
  end

  private

  def parse_options(raw_options)
    options = {}

    Array.wrap(raw_options).each do |option|
      parts = option.match(REGEX_MATCHER)
      next if parts.nil?

      namespace, key, value = parts.values_at(:namespace, :key, :value)

      namespace = namespace.strip.to_sym
      key = key.strip.to_sym
      value = value.strip.presence || true

      next if namespace.blank? || key.blank?

      namespace = NAMESPACE_ALIASES[namespace] if NAMESPACE_ALIASES[namespace]
      next unless valid_namespace?(namespace)

      options[namespace] ||= {}
      options[namespace][key] = value
    end

    options
  end

  def valid_namespace?(namespace)
    NAMESPACES.include?(namespace)
  end
end
