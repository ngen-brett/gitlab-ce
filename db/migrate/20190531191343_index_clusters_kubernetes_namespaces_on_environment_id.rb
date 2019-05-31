# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class IndexClustersKubernetesNamespacesOnEnvironmentId < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :clusters_kubernetes_namespaces, :environment_id
  end

  def down
    remove_concurrent_index :clusters_kubernetes_namespaces, :environment_id
  end
end
