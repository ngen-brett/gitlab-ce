# frozen_string_literal: true

module Gitlab
  module ErrorTracking
    class Project
      include ActiveModel::Model

      attr_accessor :id, :name, :status, :slug, :organization_name,
        :organization_id, :organization_slug
    end
  end
end
