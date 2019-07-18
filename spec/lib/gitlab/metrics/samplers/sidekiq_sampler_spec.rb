require 'spec_helper'

describe Gitlab::Metrics::Samplers::SidekiqSampler do
  let(:sampler) { described_class.new(5) }
  let(:null_metric) { double('null_metric', set: nil, observe: nil) }

  before do
    allow(Gitlab::Metrics::NullMetric).to receive(:instance).and_return(null_metric)
  end

  describe '#sample' do
    let(:sidekiq_stats) { double('sidekiq stats', processed: 3, failed: 4) }

    before do
      allow(Sidekiq::Stats).to receive(:new).and_return(sidekiq_stats)
    end

    it 'samples various statistics' do
      expect(sidekiq_stats).to receive(:processed)
      expect(sidekiq_stats).to receive(:failed)

      sampler.sample
    end

    it 'adds a metric containing number of started sidekiq jobs' do
      expect(sampler.metrics[:sidekiq_jobs_started_total]).to receive(:set).with({}, 3)

      sampler.sample
    end

    it 'adds a metric containing number of failed sidekiq jobs' do
      expect(sampler.metrics[:sidekiq_jobs_failed_total]).to receive(:set).with({}, 4)

      sampler.sample
    end
  end
end
