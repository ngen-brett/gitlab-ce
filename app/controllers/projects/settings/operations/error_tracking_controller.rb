# frozen_string_literal: true

module Projects
  module Settings
    module Operations
      class ErrorTrackingController < Projects::ApplicationController
        before_action :authorize_update_environment!
        before_action :check_feature_flag

        def create
          result = ::Projects::ErrorTracking::SettingService
            .new(project, current_user, setting_params)
            .execute

          if result[:status] == :success
            flash[:notice] = _('Your changes have been saved')
          else
            flash[:alert] = result[:message]
          end

          redirect_to project_settings_operations_path(project)
        end

        private

        def check_feature_flag
          render_404 unless Feature.enabled?(:error_tracking, current_user)
        end

        def setting_params
          params
            .require(:error_tracking_setting)
            .permit(:enabled, :uri, :token)
        end
      end
    end
  end
end
