# frozen_string_literal: true

class AddForeignKeyForContainerRepositoryUpdatedEvents < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  FK_NAME = 'fk_geo_event_log_on_container_repository_updated_event_id'

  def up
    add_concurrent_foreign_key(:geo_event_log, :geo_container_repository_updated_events, column: :container_repository_updated_event_id, name: FK_NAME, on_delete: :cascade)
  end

  def down
    if foreign_key_exists?(:geo_event_log, :geo_container_repository_updated_events)
      remove_foreign_key(:geo_event_log, name: FK_NAME)
    end
  end
end
