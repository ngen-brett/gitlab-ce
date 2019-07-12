# frozen_string_literal: true

class AddEnvironmentSlugToClustersKubernetesNamespaces < ActiveRecord::Migration[5.1]
  DOWNTIME = false

  def change
    add_column :clusters_kubernetes_namespaces, :environment_slug, :string
  end
end
