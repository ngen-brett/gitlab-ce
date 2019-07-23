# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::SidekiqMiddleware::Metrics do
  describe '#call' do
    let(:completion_time_metric) { double('completion time metric') }
    let(:middleware) { described_class.new }
    let(:worker) { double(:worker) }

    before do
      expect(Gitlab::Metrics).to receive(:histogram).with(:sidekiq_jobs_completion_seconds, anything).and_return(completion_time_metric)
    end

    it 'yields block' do
      allow(completion_time_metric).to receive(:observe)

      expect { |b| middleware.call(worker, {}, :test, &b) }.to yield_control.once
    end

    it 'sets metrics' do
      labels = { queue: :test }

      expect(completion_time_metric).to receive(:observe).with(labels.merge(type: 'user'), kind_of(Numeric))
      expect(completion_time_metric).to receive(:observe).with(labels.merge(type: 'system'), kind_of(Numeric))
      expect(completion_time_metric).to receive(:observe).with(labels.merge(type: 'real'), kind_of(Numeric))

      middleware.call(worker, {}, :test) { nil }
    end

    context 'yield raises exception' do
      it 'does not set metrics' do
        expect(completion_time_metric).not_to receive(:observe)
        expect { middleware.call(worker, {}, :test) { raise } }.to raise_error
      end
    end
  end
end
