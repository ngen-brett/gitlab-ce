# frozen_string_literal: true

class AddClusterIdToDeployments < ActiveRecord::Migration[5.1]
  DOWNTIME = false

  def change
    add_reference :deployments, :cluster, type: :integer, index: true, foreign_key: { on_delete: :nullify }
  end
end
