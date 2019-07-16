# frozen_string_literal: true

module API
  module Entities
    module ContainerRegistry
      class Repository < Grape::Entity
        expose :id
        expose :name
        expose :path
        expose :project_id
        expose :location
        expose :created_at
      end

      class Tag < Grape::Entity
        expose :name
        expose :path
        expose :location
      end

      class TagDetails < Tag
        expose :revision
        expose :short_revision
        expose :digest
        expose :created_at
        expose :total_size
      end

      class RepositoryWithTags < Repository
        expose :tags, using: Tag do |respository|
          respository.tags.map do |tag|
            {
              name: tag.name,
              path: tag.path,
              location: tag.location
            }
          end
        end
      end
    end
  end
end
