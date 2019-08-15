# frozen_string_literal: true

require 'spec_helper'

describe PrometheusMetricsFinder do
  describe '#execute' do
    it 'returns the metrics matching the provided params' do
      metric = create(:prometheus_metric)
      non_matching_metric = create(:prometheus_metric, title: 'bunk title')

      params = {
        project_id: metric.project_id,
        group: metric.group,
        title: metric.title,
        y_label: metric.y_label
      }

      metrics = described_class.new(params).execute

      expect(metrics).to eq([metric])
    end
  end
end
