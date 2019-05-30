# frozen_string_literal: true

require 'spec_helper'

describe ProjectCiCdSetting do
  describe '.available?' do
    before do
      described_class.reset_column_information
    end

    it 'returns true' do
      expect(described_class).to be_available
    end

    it 'memoizes the schema version' do
      expect(ActiveRecord::Migrator)
        .to receive(:current_version)
        .and_call_original
        .once

      2.times { described_class.available? }
    end
  end

  describe '#default_git_depth' do
    let(:default_value) { described_class::DEFAULT_GIT_DEPTH }

    it 'sets default value for new records' do
      project = create(:project)

      expect(project.ci_cd_settings.default_git_depth).to eq(default_value)
    end

    it 'does not set default value if present' do
      project = build(:project)
      project.build_ci_cd_settings(default_git_depth: 42)
      project.save!

      expect(project.reload.ci_cd_settings.default_git_depth).to eq(42)
    end
  end
end
