# frozen_string_literal: true

class ApplicationSetting < ActiveRecord::Base
  include CacheableAttributes
  include CacheMarkdownField
  include TokenAuthenticatable
  include IgnorableColumn
  include ChronicDurationAttribute

  prepend ApplicationSettingImplementation

  add_authentication_token_field :runners_registration_token, encrypted: true, fallback: true
  add_authentication_token_field :health_check_access_token

  serialize :restricted_visibility_levels # rubocop:disable Cop/ActiveRecordSerialize
  serialize :import_sources # rubocop:disable Cop/ActiveRecordSerialize
  serialize :disabled_oauth_sign_in_sources, Array # rubocop:disable Cop/ActiveRecordSerialize
  serialize :domain_whitelist, Array # rubocop:disable Cop/ActiveRecordSerialize
  serialize :domain_blacklist, Array # rubocop:disable Cop/ActiveRecordSerialize
  serialize :repository_storages # rubocop:disable Cop/ActiveRecordSerialize

  ignore_column :circuitbreaker_failure_count_threshold
  ignore_column :circuitbreaker_failure_reset_time
  ignore_column :circuitbreaker_storage_timeout
  ignore_column :circuitbreaker_access_retries
  ignore_column :circuitbreaker_check_interval
  ignore_column :koding_url
  ignore_column :koding_enabled

  cache_markdown_field :sign_in_text
  cache_markdown_field :help_page_text
  cache_markdown_field :shared_runners_text, pipeline: :plain_markdown
  cache_markdown_field :after_sign_up_text

  attr_accessor :domain_whitelist_raw, :domain_blacklist_raw

  default_value_for :id, 1

  chronic_duration_attr_writer :archive_builds_in_human_readable, :archive_builds_in_seconds

  validates :uuid, presence: true

  validates :session_expire_delay,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :home_page_url,
            allow_blank: true,
            url: true,
            if: :home_page_url_column_exists?

  validates :help_page_support_url,
            allow_blank: true,
            url: true,
            if: :help_page_support_url_column_exists?

  validates :after_sign_out_path,
            allow_blank: true,
            url: true

  validates :admin_notification_email,
            email: true,
            allow_blank: true

  validates :two_factor_grace_period,
            numericality: { greater_than_or_equal_to: 0 }

  validates :recaptcha_site_key,
            presence: true,
            if: :recaptcha_enabled

  validates :recaptcha_private_key,
            presence: true,
            if: :recaptcha_enabled

  validates :sentry_dsn,
            presence: true,
            if: :sentry_enabled

  validates :clientside_sentry_dsn,
            presence: true,
            if: :clientside_sentry_enabled

  validates :akismet_api_key,
            presence: true,
            if: :akismet_enabled

  validates :unique_ips_limit_per_user,
            numericality: { greater_than_or_equal_to: 1 },
            presence: true,
            if: :unique_ips_limit_enabled

  validates :unique_ips_limit_time_window,
            numericality: { greater_than_or_equal_to: 0 },
            presence: true,
            if: :unique_ips_limit_enabled

  validates :plantuml_url,
            presence: true,
            if: :plantuml_enabled

  validates :max_attachment_size,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 }

  validates :max_artifacts_size,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 }

  validates :default_artifacts_expire_in, presence: true, duration: true

  validates :container_registry_token_expire_delay,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 }

  validates :repository_storages, presence: true
  validate :check_repository_storages

  validates :auto_devops_domain,
            allow_blank: true,
            hostname: { allow_numeric_hostname: true, require_valid_tld: true },
            if: :auto_devops_enabled?

  validates :enabled_git_access_protocol,
            inclusion: { in: %w(ssh http), allow_blank: true, allow_nil: true }

  validates :domain_blacklist,
            presence: { message: 'Domain blacklist cannot be empty if Blacklist is enabled.' },
            if: :domain_blacklist_enabled?

  validates :housekeeping_incremental_repack_period,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 }

  validates :housekeeping_full_repack_period,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: :housekeeping_incremental_repack_period }

  validates :housekeeping_gc_period,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: :housekeeping_full_repack_period }

  validates :terminal_max_session_time,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :polling_interval_multiplier,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  validates :gitaly_timeout_default,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :gitaly_timeout_medium,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :gitaly_timeout_medium,
            numericality: { less_than_or_equal_to: :gitaly_timeout_default },
            if: :gitaly_timeout_default
  validates :gitaly_timeout_medium,
            numericality: { greater_than_or_equal_to: :gitaly_timeout_fast },
            if: :gitaly_timeout_fast

  validates :gitaly_timeout_fast,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :gitaly_timeout_fast,
            numericality: { less_than_or_equal_to: :gitaly_timeout_default },
            if: :gitaly_timeout_default

  validates :diff_max_patch_bytes,
            presence: true,
            numericality: { only_integer: true,
                            greater_than_or_equal_to: Gitlab::Git::Diff::DEFAULT_MAX_PATCH_BYTES,
                            less_than_or_equal_to: Gitlab::Git::Diff::MAX_PATCH_BYTES_UPPER_BOUND }

  validates :user_default_internal_regex, js_regex: true, allow_nil: true

  validates :commit_email_hostname, format: { with: /\A[^@]+\z/ }

  validates :archive_builds_in_seconds,
            allow_nil: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 1.day.seconds }

  validates :local_markdown_version,
            allow_nil: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 65536 }

  SUPPORTED_KEY_TYPES.each do |type|
    validates :"#{type}_key_restriction", presence: true, key_restriction: { type: type }
  end

  validates :allowed_key_types, presence: true

  validates_each :restricted_visibility_levels do |record, attr, value|
    value&.each do |level|
      unless Gitlab::VisibilityLevel.options.value?(level)
        record.errors.add(attr, "'#{level}' is not a valid visibility level")
      end
    end
  end

  validates_each :import_sources do |record, attr, value|
    value&.each do |source|
      unless Gitlab::ImportSources.options.value?(source)
        record.errors.add(attr, "'#{source}' is not a import source")
      end
    end
  end

  validate :terms_exist, if: :enforce_terms?

  before_validation :ensure_uuid!
  before_validation :strip_sentry_values

  before_save :ensure_runners_registration_token
  before_save :ensure_health_check_access_token

  after_commit do
    reset_memoized_terms
  end
  after_commit :expire_performance_bar_allowed_user_ids_cache, if: -> { previous_changes.key?('performance_bar_allowed_group_id') }

  def self.defaults
    {
      after_sign_up_text: nil,
      akismet_enabled: false,
      allow_local_requests_from_hooks_and_services: false,
      authorized_keys_enabled: true, # TODO default to false if the instance is configured to use AuthorizedKeysCommand
      container_registry_token_expire_delay: 5,
      default_artifacts_expire_in: '30 days',
      default_branch_protection: Settings.gitlab['default_branch_protection'],
      default_group_visibility: Settings.gitlab.default_projects_features['visibility_level'],
      default_project_visibility: Settings.gitlab.default_projects_features['visibility_level'],
      default_projects_limit: Settings.gitlab['default_projects_limit'],
      default_snippet_visibility: Settings.gitlab.default_projects_features['visibility_level'],
      disabled_oauth_sign_in_sources: [],
      domain_whitelist: Settings.gitlab['domain_whitelist'],
      dsa_key_restriction: 0,
      ecdsa_key_restriction: 0,
      ed25519_key_restriction: 0,
      first_day_of_week: 0,
      gitaly_timeout_default: 55,
      gitaly_timeout_fast: 10,
      gitaly_timeout_medium: 30,
      gravatar_enabled: Settings.gravatar['enabled'],
      help_page_hide_commercial_content: false,
      help_page_text: nil,
      hide_third_party_offers: false,
      housekeeping_bitmaps_enabled: true,
      housekeeping_enabled: true,
      housekeeping_full_repack_period: 50,
      housekeeping_gc_period: 200,
      housekeeping_incremental_repack_period: 10,
      import_sources: Settings.gitlab['import_sources'],
      max_artifacts_size: Settings.artifacts['max_size'],
      max_attachment_size: Settings.gitlab['max_attachment_size'],
      mirror_available: true,
      password_authentication_enabled_for_git: true,
      password_authentication_enabled_for_web: Settings.gitlab['signin_enabled'],
      performance_bar_allowed_group_id: nil,
      rsa_key_restriction: 0,
      plantuml_enabled: false,
      plantuml_url: nil,
      polling_interval_multiplier: 1,
      project_export_enabled: true,
      recaptcha_enabled: false,
      repository_checks_enabled: true,
      repository_storages: ['default'],
      require_two_factor_authentication: false,
      restricted_visibility_levels: Settings.gitlab['restricted_visibility_levels'],
      session_expire_delay: Settings.gitlab['session_expire_delay'],
      send_user_confirmation_email: false,
      shared_runners_enabled: Settings.gitlab_ci['shared_runners_enabled'],
      shared_runners_text: nil,
      sign_in_text: nil,
      signup_enabled: Settings.gitlab['signup_enabled'],
      terminal_max_session_time: 0,
      throttle_authenticated_api_enabled: false,
      throttle_authenticated_api_period_in_seconds: 3600,
      throttle_authenticated_api_requests_per_period: 7200,
      throttle_authenticated_web_enabled: false,
      throttle_authenticated_web_period_in_seconds: 3600,
      throttle_authenticated_web_requests_per_period: 7200,
      throttle_unauthenticated_enabled: false,
      throttle_unauthenticated_period_in_seconds: 3600,
      throttle_unauthenticated_requests_per_period: 3600,
      two_factor_grace_period: 48,
      unique_ips_limit_enabled: false,
      unique_ips_limit_per_user: 10,
      unique_ips_limit_time_window: 3600,
      usage_ping_enabled: Settings.gitlab['usage_ping_enabled'],
      instance_statistics_visibility_private: false,
      user_default_external: false,
      user_default_internal_regex: nil,
      user_show_add_ssh_key_message: true,
      usage_stats_set_by_user_id: nil,
      diff_max_patch_bytes: Gitlab::Git::Diff::DEFAULT_MAX_PATCH_BYTES,
      commit_email_hostname: default_commit_email_hostname,
      protected_ci_variables: false,
      local_markdown_version: 0
    }
  end

  def self.default_commit_email_hostname
    "users.noreply.#{Gitlab.config.gitlab.host}"
  end

  def self.create_from_defaults
    build_from_defaults.tap(&:save)
  end

  def self.human_attribute_name(attr, _options = {})
    if attr == :default_artifacts_expire_in
      'Default artifacts expiration'
    else
      super
    end
  end
end
