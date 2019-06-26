# frozen_string_literal: true

class ImportCommonMetrics < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    Importers::CommonMetricsImporter.new.execute
  end

  def down
    # no-op
  end
end
