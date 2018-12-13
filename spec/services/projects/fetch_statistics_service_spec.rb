# frozen_string_literal: true

require 'spec_helper'

module Projects
  describe FetchStatisticsService do
    let(:project) { create(:project) }

    describe '#execute' do
      subject { described_class.new(project).execute }

      it 'creates a new record for today with count == 1' do
        expect { subject }.to change { ProjectFetchStatistic.count }.by(1)
        created_stat = ProjectFetchStatistic.last

        expect(created_stat.count).to eq(1)
        expect(created_stat.project).to eq(project)
        expect(created_stat.date).to eq(Date.today)
      end

      context 'when the record already exists for today' do
        let!(:project_fetch_stat) { create(:project_fetch_statistic, project: project) }

        it 'increments the today record count by 1' do
          expect { subject }.to change { project_fetch_stat.reload.count }.to(2)
        end
      end
    end
  end
end
