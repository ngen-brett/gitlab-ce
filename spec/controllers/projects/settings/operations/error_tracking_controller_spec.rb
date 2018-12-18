# frozen_string_literal: true

require 'spec_helper'

describe Projects::Settings::Operations::ErrorTrackingController do
  set(:user) { create(:user) }
  set(:project) { create(:project) }

  before do
    sign_in(user)
  end

  describe 'POST #create' do
    before do
      project.add_maintainer(user)
    end

    let(:setting_service) { spy(:setting_service) }

    let(:operations_url) do
      "http://test.host/#{project.namespace.path}/#{project.path}/settings/operations"
    end
    let(:error_tracking_params) do
      {
        enabled: '1',
        uri: 'http://url',
        token: 'token'
      }
    end
    let(:error_tracking_permitted) do
      ActionController::Parameters.new(error_tracking_params).permit!
    end

    context 'when update succeeds' do
      before do
        stub_setting_service_returning(status: :success)
      end

      it 'shows a notice' do
        post :create, params: project_params(project, error_tracking_params)

        expect(response).to redirect_to(operations_url)
        expect(flash[:notice]).to eq _('Your changes have been saved')
      end
    end

    context 'when update fails' do
      before do
        stub_setting_service_returning(status: :error, message: error_message)
      end

      let(:error_message) { 'error message' }

      it 'shows an alert' do
        post :create, params: project_params(project, error_tracking_params)

        expect(response).to redirect_to(operations_url)
        expect(flash[:alert]).to eq error_message
      end
    end

    context 'as a reporter' do
      before do
        project.add_reporter(user)
      end

      it 'renders 404' do
        post :create, params: project_params(project)

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'as an anonymous user' do
      before do
        sign_out(user)
      end

      it 'redirects to signup page' do
        post :create, params: project_params(project)

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  private

  def project_params(project, params = {})
    {
      namespace_id: project.namespace,
      project_id: project,
      error_tracking_setting: params
    }
  end

  def stub_setting_service_returning(return_value = {})
    expect(::Projects::ErrorTracking::SettingService)
      .to receive(:new).with(project, user, error_tracking_permitted)
      .and_return(setting_service)
    expect(setting_service).to receive(:execute)
      .and_return(return_value)
  end
end
