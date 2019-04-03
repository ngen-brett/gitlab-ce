# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class BackportEeSchema < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  disable_ddl_transaction!

  class ApplicationSetting < ActiveRecord::Base
    self.table_name = 'application_settings'
  end

  def up
    add_column_if_not_exists(:appearances, :updated_by, :integer)

    # In the CE schema this column allows NULL values even though there is a
    # default value. In EE this column is not allowed to be NULL. This means
    # that if we want to add a NOT NULL clause below, we must ensure no existing
    # data would violate this clause.
    ApplicationSetting
      .where(password_authentication_enabled_for_git: nil)
      .update_all(password_authentication_enabled_for_git: true)

    change_column_null(
      :application_settings,
      :password_authentication_enabled_for_git,
      false
    )

    # This table will only have a single row, and all operations here will be
    # very fast. As such we merge all of this into a single ALTER TABLE
    # statement.
    change_table(:application_settings) do |t|
      t.text(:help_text) unless t.column_exists?(:help_text)

      [
        { type: :boolean, name: :elasticsearch_indexing, default: false, null: false },
        { type: :boolean, name: :elasticsearch_search, default: false, null: false },
        { type: :integer, name: :shared_runners_minutes, default: 0, null: false },
        { type: :bigint, name: :repository_size_limit, default: 0, null: true },
        { type: :string, name: :elasticsearch_url, default: "http://localhost:9200" },
        { type: :boolean, name: :elasticsearch_aws, default: false, null: false },
        { type: :string, name: :elasticsearch_aws_region, default: "us-east-1", null: false },
        { type: :string, name: :elasticsearch_aws_access_key, default: nil, null: true },
        { type: :string, name: :elasticsearch_aws_secret_access_key, default: nil, null: true },
        { type: :integer, name: :geo_status_timeout, default: 10, null: true },
        { type: :boolean, name: :elasticsearch_experimental_indexer, default: nil, null: true },
        { type: :boolean, name: :check_namespace_plan, default: false, null: false },
        { type: :integer, name: :mirror_max_delay, default: 300, null: false },
        { type: :integer, name: :mirror_max_capacity, default: 100, null: false },
        { type: :integer, name: :mirror_capacity_threshold, default: 50, null: false },
        { type: :boolean, name: :slack_app_enabled, default: false },
        { type: :string, name: :slack_app_id },
        { type: :string, name: :slack_app_secret },
        { type: :string, name: :slack_app_verification_token },
        { type: :boolean, name: :allow_group_owners_to_manage_ldap, default: true, null: false },
        { type: :integer, name: :default_project_creation, default: 2, null: false },
        { type: :boolean, name: :external_authorization_service_enabled, default: false, null: false },
        { type: :string, name: :external_authorization_service_url },
        { type: :string, name: :external_authorization_service_default_label },
        { type: :float, name: :external_authorization_service_timeout, default: 0.5 },
        { type: :text, name: :external_auth_client_cert },
        { type: :text, name: :encrypted_external_auth_client_key },
        { type: :string, name: :encrypted_external_auth_client_key_iv },
        { type: :string, name: :encrypted_external_auth_client_key_pass },
        { type: :string, name: :encrypted_external_auth_client_key_pass_iv },
        { type: :string, name: :email_additional_text },
        { type: :integer, name: :file_template_project_id },
        { type: :boolean, name: :pseudonymizer_enabled, default: false, null: false },
        { type: :boolean, name: :snowplow_enabled, default: false, null: false },
        { type: :string, name: :snowplow_collector_uri },
        { type: :string, name: :snowplow_site_id },
        { type: :string, name: :snowplow_cookie_domain },
        { type: :integer, name: :custom_project_templates_group_id },
        { type: :boolean, name: :elasticsearch_limit_indexing, default: false, null: false }
      ].each do |field|
        next if t.column_exists?(field[:name])

        t.public_send(
          field[:type],
          field[:name],
          default: field[:default],
          null: field.fetch(:null, true)
        )
      end

      t.index(
        [:custom_project_templates_group_id],
        name: :index_application_settings_on_custom_project_templates_group_id,
        using: :btree
      )

      t.index(
        [:file_template_project_id],
        name: :index_application_settings_on_file_template_project_id,
        using: :btree
      )
    end
  end

  def down
  end

  def add_column_if_not_exists(table, name, type)
    add_column(table, name, type) unless column_exists?(table, name)
  end
end
