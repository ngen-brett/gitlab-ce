# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddTrigramIndexToSnippetsContent < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    return unless Gitlab::Database.postgresql?

    unless trigrams_enabled?
      raise 'You must enable the pg_trgm extension as a PostgreSQL super user'
    end

    execute "CREATE INDEX CONCURRENTLY index_snippets_on_content_trigram ON snippets USING gin(content gin_trgm_ops);"
  end

  def down
    return unless Gitlab::Database.postgresql?

    unless trigrams_enabled?
      raise 'You must enable the pg_trgm extension as a PostgreSQL super user'
    end

    remove_index :snippets, name: "index_snippets_on_content_trigram"
  end

  def trigrams_enabled?
    res = execute("SELECT true AS enabled FROM pg_available_extensions WHERE name = 'pg_trgm' AND installed_version IS NOT NULL;")
    row = res.first

    row && row['enabled'] == true
  end
end
