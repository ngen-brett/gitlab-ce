# frozen_string_literal: true
require 'spec_helper'

describe ProjectFetchStatisticsWorker, '#perform' do
  let(:worker) { described_class.new }
  let(:project) { create(:project) }

  it 'calls fetch_statistics_service with the given project' do
    expect_next_instance_of(Projects::FetchStatisticsService, project) do |service|
      expect(service).to receive(:execute)
    end
    worker.perform(project.id)
  end
end
