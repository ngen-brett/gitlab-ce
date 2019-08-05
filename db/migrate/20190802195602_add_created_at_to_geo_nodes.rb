# frozen_string_literal: true

class AddCreatedAtToGeoNodes < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def change
    add_column(:geo_nodes, :created_at, :datetime_with_timezone, null: true)
  end
end
