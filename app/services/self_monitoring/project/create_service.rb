# frozen_string_literal: true

module SelfMonitoring
  module Project
    class CreateService
      DEFAULT_VISIBILITY_LEVEL = Gitlab::VisibilityLevel::INTERNAL
      DEFAULT_NAME = 'GitLab Instance Administration'

      def execute
        admin_user = User.admins.active.first

        project = ::Projects::CreateService.new(admin_user, create_project_params).execute

        if add_prometheus_manual_configuration(project) == false
          Rails.logger.warn("Could not connect self monitoring project to internal prometheus")
        end

        project
      end

      private

      def create_project_params
        {
          initialize_with_readme: true,
          visibility_level: DEFAULT_VISIBILITY_LEVEL,
          name: DEFAULT_NAME
        }
      end

      def internal_prometheus_listen_address
        Settings.prometheus.listen_address
      end

      def prometheus_service_attributes
        {
          api_url: internal_prometheus_listen_address,
          manual_configuration: true,
          active: true
        }
      end

      def add_prometheus_manual_configuration(project)
        return unless Settings.prometheus && Settings.prometheus.enable

        service = project.find_or_initialize_service('prometheus')
        service.attributes = prometheus_service_attributes

        service.save
      end
    end
  end
end
