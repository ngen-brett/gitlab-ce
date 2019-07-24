# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::SidekiqMiddleware::Metrics do
  describe '#call' do
    let(:middleware) { described_class.new }
    let(:worker) { double(:worker) }

    let(:completion_seconds_metric) { double('completion seconds metric') }
    let(:failed_total_metric) { double('failed total metric') }
    let(:retried_total_metric) { double('retried total metric') }
    let(:started_total_metric) { double('started total metric') }

    before do
      allow(Gitlab::Metrics).to receive(:histogram).with(:sidekiq_jobs_completion_seconds, anything).and_return(completion_seconds_metric)
      allow(Gitlab::Metrics).to receive(:counter).with(:sidekiq_jobs_failed_total, anything).and_return(failed_total_metric)
      allow(Gitlab::Metrics).to receive(:counter).with(:sidekiq_jobs_retried_total, anything).and_return(retried_total_metric)
      allow(Gitlab::Metrics).to receive(:counter).with(:sidekiq_jobs_started_total, anything).and_return(started_total_metric)
    end

    it 'yields block' do
      allow(started_total_metric).to receive(:increment)
      allow(completion_seconds_metric).to receive(:observe)

      expect { |b| middleware.call(worker, {}, :test, &b) }.to yield_control.once
    end

    it 'sets metrics' do
      labels = { queue: :test }

      expect(started_total_metric).to receive(:increment)
      expect(completion_seconds_metric).to receive(:observe).with(labels.merge(type: 'user'), kind_of(Numeric))
      expect(completion_seconds_metric).to receive(:observe).with(labels.merge(type: 'system'), kind_of(Numeric))
      expect(completion_seconds_metric).to receive(:observe).with(labels.merge(type: 'real'), kind_of(Numeric))

      middleware.call(worker, {}, :test) { nil }
    end

    context 'when job is retried' do
      it 'sets sidekiq_jobs_retried_total metric' do
        allow(started_total_metric).to receive(:increment)
        allow(completion_seconds_metric).to receive(:observe)

        expect(retried_total_metric).to receive(:increment)

        middleware.call(worker, { 'retry_count' => 1 }, :test) { nil }
      end
    end

    context 'when error is raised' do
      it 'sets sidekiq_jobs_failed_total and reraises' do
        allow(started_total_metric).to receive(:increment)

        expect(failed_total_metric).to receive(:increment)
        expect { middleware.call(worker, {}, :test) { raise } }.to raise_error
      end
    end
  end
end
