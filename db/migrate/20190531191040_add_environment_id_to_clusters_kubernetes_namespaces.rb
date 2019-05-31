# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddEnvironmentIdToClustersKubernetesNamespaces < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_column :clusters_kubernetes_namespaces, :environment_id, :integer
  end
end
