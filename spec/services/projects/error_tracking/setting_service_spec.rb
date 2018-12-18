# frozen_string_literal: true

require 'spec_helper'

describe Projects::ErrorTracking::SettingService do
  set(:user) { create(:user) }
  set(:project) { create(:project) }
  let(:result) { described_class.new(project, user, params).execute }

  let(:params) do
    {
      enabled: true,
      uri: 'http://error_tracking.url',
      token: 'token'
    }
  end

  describe '#execute' do
    context 'with existing error tracking setting' do
      before do
        create(:error_tracking_setting, project: project)
      end

      let(:params) do
        {
          enabled: false,
          uri: 'http://something',
          token: 'another token'
        }
      end

      it 'updates the settings' do
        expect(result[:status]).to eq(:success)

        project.reload
        expect(project.error_tracking_setting).not_to be_enabled
        expect(project.error_tracking_setting.uri).to eq('http://something')
        expect(project.error_tracking_setting.token).to eq('another token')
      end
    end

    context 'without an existing error tracking setting' do
      it 'creates a setting' do
        expect(result[:status]).to eq(:success)

        expect(project.error_tracking_setting).to be_enabled
        expect(project.error_tracking_setting.uri).to eq('http://error_tracking.url')
        expect(project.error_tracking_setting.token).to eq('token')
      end
    end

    context 'with invalid parameters' do
      let(:params) do
        {
        }
      end

      it 'fails to create the setting' do
        expect(result[:status]).to eq(:error)
        expect(result[:message]).to match(/valid URL/)
        expect(result[:message]).to match(/be blank/)
      end
    end
  end
end
