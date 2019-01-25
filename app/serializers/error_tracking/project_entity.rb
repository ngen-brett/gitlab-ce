# frozen_string_literal: true

module ErrorTracking
  class ProjectEntity < Grape::Entity
    expose :id, :name, :status, :slug, :organization_name,
    :organization_id, :organization_slug
  end
end
