# frozen_string_literal: true

module Projects
  module Settings
    class OperationsController < Projects::ApplicationController
      before_action :authorize_update_environment!, only: [:show]

      def show
        @error_tracking_setting = ::ErrorTracking::ErrorTrackingSetting.for_project(project)
      end
    end
  end
end
