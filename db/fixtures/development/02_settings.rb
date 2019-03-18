# frozen_string_literal: true

# Enable hashed storage, in development mode, for all projects by default.
Gitlab::Seeder.quiet do
  Gitlab::CurrentSettings.current_application_settings
  ApplicationSetting.current_without_cache.update!(hashed_storage_enabled: true)
  print '.'
end
