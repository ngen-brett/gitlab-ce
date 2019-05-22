# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # This migration takes data from properties field of issue trackers (services table)
    # and copies them to separate tables.
    #
    # The data are kept in the services table and will be removed as the next step
    class MigrateIssueTrackersSensitiveData
      delegate :select_all, :execute, :quote_string, to: :connection

      # we need to define this class because of the encryption
      class JiraTrackerData < ActiveRecord::Base
        self.table_name = 'jira_tracker_data'

        def self.encryption_options
          {
            key: Settings.attr_encrypted_db_key_base_32,
            encode: true,
            mode: :per_attribute_iv,
            algorithm: 'aes-256-gcm'
          }
        end

        attr_encrypted :url, encryption_options
        attr_encrypted :api_url, encryption_options
        attr_encrypted :username, encryption_options
        attr_encrypted :password, encryption_options
      end

      # we need to define this class because of the encryption
      class IssueTrackerData < ActiveRecord::Base
        self.table_name = 'issue_tracker_data'

        def self.encryption_options
          {
            key: Settings.attr_encrypted_db_key_base_32,
            encode: true,
            mode: :per_attribute_iv,
            algorithm: 'aes-256-gcm'
          }
        end

        attr_encrypted :project_url, encryption_options
        attr_encrypted :issues_url, encryption_options
        attr_encrypted :new_issue_url, encryption_options
      end

      def perform
        migrate_trackers_data
      end

      private

      def migrate_trackers_data
        issue_tracker_services = ['JiraService', 'BugzillaService', 'YoutrackService', 'RedmineService', 'CustomIssueTrackerService']
        issue_tracker_services.each do |service_type|
          select_all(query(service_type)).map do |service|
            properties = JSON.parse(service["properties"])
            case service_type
            when 'JiraService'
              data = jira_mapping(properties)
              klass = JiraTrackerData
            else
              data = trackers_mapping(properties)
              klass = IssueTrackerData
            end

            klass.create(data.merge(service_id: service["id"]))
          end
        end
      end

      def query(service)
        "SELECT id, properties FROM services WHERE services.type IN ('#{service}')"
      end

      def jira_mapping(properties)
        {
          url: properties["url"],
          api_url: properties['api_url'],
          username: properties['username'],
          password: properties['password'],
          jira_issue_transition_id: properties['jira_issue_transition_id']
        }
      end

      def trackers_mapping(properties)
        {
          project_url: properties["project_url"],
          new_issue_url: properties['new_issue_url'],
          issues_url: properties['issues_url']
        }
      end

      def connection
        ActiveRecord::Base.connection
      end
    end
  end
end
