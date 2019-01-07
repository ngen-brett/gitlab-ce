# frozen_string_literal: true

require 'fast_spec_helper'

describe Gitlab::Tracing::JaegerFactory do
  describe '.create_tracer' do
    let(:service_name) { 'rspec' }

    it 'processes default connections' do
      expect(described_class.create_tracer(service_name, {})).not_to be_nil()
    end

    it 'handles debug options' do
      expect(described_class.create_tracer(service_name, { debug: "1" })).not_to be_nil()
    end

    it 'handles const sampler' do
      expect(described_class.create_tracer(service_name, { sampler: "const", sampler_param: "1" })).not_to be_nil()
    end

    it 'handles probabilistic sampler' do
      expect(described_class.create_tracer(service_name, { sampler: "probabilistic", sampler_param: "0.5" })).not_to be_nil()
    end

    it 'handles http_endpoint configurations' do
      expect(described_class.create_tracer(service_name, { http_endpoint: "http://localhost:1234" })).not_to be_nil()
    end

    it 'handles udp_endpoint configurations' do
      expect(described_class.create_tracer(service_name, { udp_endpoint: "localhost:4321" })).not_to be_nil()
    end
  end
end
