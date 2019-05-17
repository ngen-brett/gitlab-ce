# frozen_string_literal: true

class ChangePackagesSizeDefaultsInProjectStatistics < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    change_column :project_statistics, :packages_size, :bigint, default: 0

    update_column_in_batches(:project_statistics, :packages_size, 0) do |table, query|
      query.where(table[:packages_size].eq(nil))
    end

    change_column :project_statistics, :packages_size, :bigint, null: false
  end

  def down
    change_column :project_statistics, :packages_size, :bigint, default: nil, null: true
  end
end
