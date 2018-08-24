class AddOutboundRequestsWhitelistToApplicationSettings < ActiveRecord::Migration

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  def change
    add_column :application_settings, :outbound_requests_whitelist, :text
  end
end
