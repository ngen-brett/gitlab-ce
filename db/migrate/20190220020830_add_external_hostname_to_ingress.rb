# frozen_string_literal: true

class AddExternalHostnameToIngress < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_column :clusters_applications_ingress, :external_hostname, :string
  end
end
