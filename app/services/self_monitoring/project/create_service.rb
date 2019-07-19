# frozen_string_literal: true

module SelfMonitoring
  module Project
    class CreateService < ::BaseService
      include Stepable

      VISIBILITY_LEVEL = Gitlab::VisibilityLevel::INTERNAL
      PROJECT_NAME = 'GitLab Instance Administration'
      PROJECT_DESCRIPTION = <<~HEREDOC
        This project is automatically generated and will be used to help monitor this GitLab instance.
      HEREDOC

      GROUP_NAME = 'GitLab Instance Administrators'
      GROUP_PATH = 'gitlab-instance-administrators'

      steps :validate_admins,
        :create_group,
        :create_project,
        :add_group_members,
        :add_prometheus_manual_configuration

      def initialize
        super(nil)
      end

      def execute
        execute_steps
      end

      private

      def validate_admins
        unless instance_admins.any?
          log_error('No active admin user found')
          return error('No active admin user found')
        end

        success
      end

      def create_group
        admin_user = group_owner
        @group = ::Groups::CreateService.new(admin_user, create_group_params).execute

        if @group.persisted?
          success(group: @group)
        else
          error('Could not create group')
        end
      end

      def create_project
        admin_user = group_owner
        @project = ::Projects::CreateService.new(admin_user, create_project_params).execute

        if project.persisted?
          success(project: project)
        else
          log_error("Could not create self-monitoring project. Errors: #{project.errors.full_messages}")
          error('Could not create project')
        end
      end

      def add_group_members
        members = @group.add_users(group_maintainers, Gitlab::Access::MAINTAINER)
        errors = members.flat_map { |member| member.errors.full_messages }

        if errors.any?
          log_error("Could not add admins as members to self-monitoring project. Errors: #{errors}")
          error('Could not add admins as members')
        else
          success
        end
      end

      def add_prometheus_manual_configuration
        return success unless prometheus_enabled?
        return success unless prometheus_listen_address.present?

        # TODO: Currently, adding the internal prometheus server as a manual configuration
        # is only possible if the setting to allow webhooks and services to connect
        # to local network is on.
        # https://gitlab.com/gitlab-org/gitlab-ce/issues/44496 will add
        # a whitelist that will allow connections to certain ips on the local network.

        service = project.find_or_initialize_service('prometheus')

        unless service.update(prometheus_service_attributes)
          log_error("Could not save prometheus manual configuration for self-monitoring project. Errors: #{service.errors.full_messages}")
          return error('Could not save prometheus manual configuration')
        end

        success
      end

      def prometheus_enabled?
        Gitlab.config.prometheus.enable
      rescue Settingslogic::MissingSetting
        false
      end

      def prometheus_listen_address
        Gitlab.config.prometheus.listen_address
      rescue Settingslogic::MissingSetting
      end

      def instance_admins
        @instance_admins ||= User.admins.active
      end

      def group_owner
        instance_admins.first
      end

      def group_maintainers
        # Exclude the first so that the group_owner is not added again as a member.
        instance_admins - [group_owner]
      end

      def create_group_params
        {
          name: GROUP_NAME,
          path: GROUP_PATH,
          visibility_level: VISIBILITY_LEVEL
        }
      end

      def create_project_params
        {
          initialize_with_readme: true,
          visibility_level: VISIBILITY_LEVEL,
          name: PROJECT_NAME,
          description: PROJECT_DESCRIPTION,
          namespace_id: @group.id
        }
      end

      def internal_prometheus_listen_address_uri
        if prometheus_listen_address.starts_with?('http')
          prometheus_listen_address
        else
          'http://' + prometheus_listen_address
        end
      end

      def prometheus_service_attributes
        {
          api_url: internal_prometheus_listen_address_uri,
          manual_configuration: true,
          active: true
        }
      end
    end
  end
end
