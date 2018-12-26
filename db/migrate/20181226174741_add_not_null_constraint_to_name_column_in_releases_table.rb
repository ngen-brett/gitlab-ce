# frozen_string_literal: true

class AddNotNullConstraintToNameColumnInReleasesTable < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    change_column_null :releases, :name, false
  end

  def down
    change_column_null :releases, :name, true
  end
end
