# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::SidekiqMiddleware::Metrics do
  describe "#call" do
    it 'sets metrics' do
      middleware = described_class.new
      labels = { class: 'TestWorker' }
      worker = double(:worker, class: 'TestWorker')

      completion_time_metric = double('completion time metric')
      memory_allocated_metric = double('memory allocated metric')

      expect(Gitlab::Metrics).to receive(:histogram).with(:sidekiq_jobs_completion_time, anything).and_return(completion_time_metric)
      expect(Gitlab::Metrics).to receive(:histogram).with(:sidekiq_jobs_memory_allocated_bytes, anything).and_return(memory_allocated_metric)

      expect(completion_time_metric).to receive(:observe).with(labels, kind_of(Numeric))
      expect(memory_allocated_metric).to receive(:observe).with(labels, kind_of(Numeric))

      middleware.call(worker, {}, :test) { nil }
    end
  end
end
