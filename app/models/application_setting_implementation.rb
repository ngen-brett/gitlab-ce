module ApplicationSettingImplementation
  DOMAIN_LIST_SEPARATOR = %r{\s*[,;]\s*     # comma or semicolon, optionally surrounded by whitespace
                            |               # or
                            \s              # any whitespace character
                            |               # or
                            [\r\n]          # any number of newline characters
                          }x

  # Setting a key restriction to `-1` means that all keys of this type are
  # forbidden.
  FORBIDDEN_KEY_VALUE = KeyRestrictionValidator::FORBIDDEN
  SUPPORTED_KEY_TYPES = %i[rsa dsa ecdsa ed25519].freeze

  def home_page_url_column_exists?
    ::Gitlab::Database.cached_column_exists?(:application_settings, :home_page_url)
  end

  def help_page_support_url_column_exists?
    ::Gitlab::Database.cached_column_exists?(:application_settings, :help_page_support_url)
  end

  def disabled_oauth_sign_in_sources=(sources)
    sources = (sources || []).map(&:to_s) & Devise.omniauth_providers.map(&:to_s)
    super(sources)
  end

  def domain_whitelist_raw
    self.domain_whitelist&.join("\n")
  end

  def domain_blacklist_raw
    self.domain_blacklist&.join("\n")
  end

  def domain_whitelist_raw=(values)
    self.domain_whitelist = []
    self.domain_whitelist = values.split(DOMAIN_LIST_SEPARATOR)
    self.domain_whitelist.reject! { |d| d.empty? }
    self.domain_whitelist
  end

  def domain_blacklist_raw=(values)
    self.domain_blacklist = []
    self.domain_blacklist = values.split(DOMAIN_LIST_SEPARATOR)
    self.domain_blacklist.reject! { |d| d.empty? }
    self.domain_blacklist
  end

  def domain_blacklist_file=(file)
    self.domain_blacklist_raw = file.read
  end

  def repository_storages
    Array(read_attribute(:repository_storages))
  end

  def commit_email_hostname
    super.presence || self.class.default_commit_email_hostname
  end

  def default_project_visibility=(level)
    super(Gitlab::VisibilityLevel.level_value(level))
  end

  def default_snippet_visibility=(level)
    super(Gitlab::VisibilityLevel.level_value(level))
  end

  def default_group_visibility=(level)
    super(Gitlab::VisibilityLevel.level_value(level))
  end

  def restricted_visibility_levels=(levels)
    super(levels&.map { |level| Gitlab::VisibilityLevel.level_value(level) })
  end

  def strip_sentry_values
    sentry_dsn.strip! if sentry_dsn.present?
    clientside_sentry_dsn.strip! if clientside_sentry_dsn.present?
  end

  def performance_bar_allowed_group
    Group.find_by_id(performance_bar_allowed_group_id)
  end

  # Return true if the Performance Bar is enabled for a given group
  def performance_bar_enabled
    performance_bar_allowed_group_id.present?
  end

  # Choose one of the available repository storage options. Currently all have
  # equal weighting.
  def pick_repository_storage
    repository_storages.sample
  end

  def runners_registration_token
    ensure_runners_registration_token!
  end

  def health_check_access_token
    ensure_health_check_access_token!
  end

  def usage_ping_can_be_configured?
    Settings.gitlab.usage_ping_enabled
  end

  def usage_ping_enabled
    usage_ping_can_be_configured? && super
  end

  def allowed_key_types
    SUPPORTED_KEY_TYPES.select do |type|
      key_restriction_for(type) != FORBIDDEN_KEY_VALUE
    end
  end

  def key_restriction_for(type)
    attr_name = "#{type}_key_restriction"

    has_attribute?(attr_name) ? public_send(attr_name) : FORBIDDEN_KEY_VALUE # rubocop:disable GitlabSecurity/PublicSend
  end

  def allow_signup?
    signup_enabled? && password_authentication_enabled_for_web?
  end

  def password_authentication_enabled?
    password_authentication_enabled_for_web? || password_authentication_enabled_for_git?
  end

  def user_default_internal_regex_enabled?
    user_default_external? && user_default_internal_regex.present?
  end

  def user_default_internal_regex_instance
    Regexp.new(user_default_internal_regex, Regexp::IGNORECASE)
  end

  delegate :terms, to: :latest_terms, allow_nil: true
  def latest_terms
    @latest_terms ||= ApplicationSetting::Term.latest
  end

  def reset_memoized_terms
    @latest_terms = nil
    latest_terms
  end

  def archive_builds_older_than
    archive_builds_in_seconds.seconds.ago if archive_builds_in_seconds
  end

  private

  def ensure_uuid!
    return if uuid?

    self.uuid = SecureRandom.uuid
  end

  def check_repository_storages
    invalid = repository_storages - Gitlab.config.repositories.storages.keys
    errors.add(:repository_storages, "can't include: #{invalid.join(", ")}") unless
      invalid.empty?
  end

  def terms_exist
    return unless enforce_terms?

    errors.add(:terms, "You need to set terms to be enforced") unless terms.present?
  end

  def expire_performance_bar_allowed_user_ids_cache
    Gitlab::PerformanceBar.expire_allowed_user_ids_cache
  end
end
