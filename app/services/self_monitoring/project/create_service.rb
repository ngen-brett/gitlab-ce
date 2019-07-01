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
        project = create_project

        add_prometheus_manual_configuration(project)

        add_project_members(project)

        # EE only
        setup_alertmanager(project)

        project
      end

      private

      def create_project
        admin_user = project_owner

        unless admin_user
          raise NoAdminUsersError, 'No active admin user found'
        end

        ::Projects::CreateService.new(admin_user, create_project_params).execute
      end

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
