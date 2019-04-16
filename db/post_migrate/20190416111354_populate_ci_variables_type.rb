# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class PopulateCiVariablesType < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  ENV_VAR_VARIABLE_TYPE = 1

  disable_ddl_transaction!

  def up
    %i(ci_group_variables ci_pipeline_schedule_variables ci_pipeline_variables ci_variables).each do |table_name|
      update_column_in_batches(table_name, :variable_type, ENV_VAR_VARIABLE_TYPE) do |table, query|
        query.where(table[:variable_type].eq(nil))
      end
    end
  end

  def down
  end
end
