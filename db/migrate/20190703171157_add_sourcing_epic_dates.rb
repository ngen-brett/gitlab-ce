# frozen_string_literal: true

class AddSourcingEpicDates < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_column :epics, :start_date_sourcing_epic_id, :integer
    add_column :epics, :end_date_sourcing_epic_id, :integer
  end
end
