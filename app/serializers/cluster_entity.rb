# frozen_string_literal: true

class ClusterEntity < Grape::Entity
  include RequestAwareEntity

  expose :name
  expose :path do |cluster|
    cluster.present.show_path
  end
  expose :status_name, as: :status
  expose :status_reason
  expose :applications, using: ClusterApplicationEntity
end
