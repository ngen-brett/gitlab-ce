# frozen_string_literal: true

class IndexClustersKubernetesNamespacesOnEnvironmentSlug < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'index_kubernetes_namespaces_on_project_id_and_environment_slug'

  disable_ddl_transaction!

  def up
    add_concurrent_index :clusters_kubernetes_namespaces, [:project_id, :environment_slug], unique: true, name: INDEX_NAME
  end

  def down
    remove_concurrent_index :clusters_kubernetes_namespaces, name: INDEX_NAME
  end
end
