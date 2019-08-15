# frozen_string_literal: true

class PrometheusMetricsFinder
  attr_reader :params

  # @params [Hash<Symbol, any>] representing any prometheus metrics column
  def initialize(params = {})
    @params = params
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def execute
    PrometheusMetric.where(params)
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
