# frozen_string_literal: true

module SelfMonitoring
  module Project
    class CreateService
      DEFAULT_VISIBILITY_LEVEL = Gitlab::VisibilityLevel::INTERNAL
      DEFAULT_NAME = 'GitLab Instance Administration'
      DEFAULT_DESCRIPTION = <<~HEREDOC
      This project is automatically generated and will be used to help monitor this GitLab instance.
      HEREDOC

      NoAdminUsersError = Class.new(StandardError)
      NoPrometheusSettingInGitlabYml = Class.new(StandardError)

      def execute
        admin_user = project_owner

        unless admin_user
          raise NoAdminUsersError, 'No active admin user found'
        end

        project = ::Projects::CreateService.new(admin_user, create_project_params).execute

        add_prometheus_manual_configuration(project)

        add_project_members(project)

        # Generate alertmanager token (EE)
        setup_alertmanager(project)

        project
      end

      private

      # This function is overridden in EE
      def setup_alertmanager(project)
      end

      def add_project_members(project)
        admins = User.admins.active - [project.owner]
        ProjectMember.add_users(project, admins, :maintainer)
      end

      def project_owner
        User.admins.active.first
      end

      def create_project_params
        {
          initialize_with_readme: true,
          visibility_level: DEFAULT_VISIBILITY_LEVEL,
          name: DEFAULT_NAME,
          description: DEFAULT_DESCRIPTION
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
        begin
          return unless Settings.prometheus.enable
        rescue Settingslogic::MissingSetting
          raise NoPrometheusSettingInGitlabYml, 'No prometheus setting in gitlab.yml'
        end

        service = project.find_or_initialize_service('prometheus')
        service.attributes = prometheus_service_attributes

        service.save
      end
    end
  end
end
