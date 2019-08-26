# frozen_string_literal: true

danger.import_plugin('danger/plugins/helper.rb')
danger.import_plugin('danger/plugins/roulette.rb')

DANGERFILES_LOCAL = %w{
  changes_size
  gemfile
  documentation
  frozen_string
  duplicate_yarn_dependencies
  prettier
  eslint
}.freeze

DANGERFILES_CI_ONLY = %w{
  metadata
  changelog
  specs
  database
  commit_messages
  roulette
  single_codebase
  gitlab_ui_wg
  ce_ee_vue_templates
  only_documentation
}.freeze

all_danger_files = DANGERFILES_LOCAL

if ENV['CI'] && !helper.release_automation?
  all_danger_files += DANGERFILES_CI_ONLY
end

all_danger_files.each do |file|
  danger.import_dangerfile(path: File.join('danger', file))
end
