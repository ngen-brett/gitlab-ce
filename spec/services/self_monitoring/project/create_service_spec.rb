# frozen_string_literal: true

require 'spec_helper'

describe SelfMonitoring::Project::CreateService do
  describe '#execute' do
    subject { described_class.new.execute }

    it 'creates project with internal visibility' do
      expect(subject.visibility_level).to eq(Gitlab::VisibilityLevel::INTERNAL)
    end

    it 'creates project with name' do
      expect(subject.name).to eq(described_class::DEFAULT_NAME)
    end

    it 'has prometheus service' do
      prometheus = subject.prometheus_service
      expect(prometheus).not_to eq(nil)
      expect(prometheus.api_url).to eq('localhost:9090')
      expect(prometheus.active).to eq(true)
      expect(prometheus.manual_configuration).to eq(true)
    end
  end
end
