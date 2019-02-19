# frozen_string_literal: true

class AddMergePipelinesEnabledToCiCdSettings < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def change
    add_column_with_default :project_ci_cd_settings, :merge_pipelines_enabled, :boolean, default: false, allow_null: false
  end
end
