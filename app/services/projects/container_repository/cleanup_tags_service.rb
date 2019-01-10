# frozen_string_literal: true

module Projects
  module ContainerRepository
    class CleanupTagsService < BaseService
      def execute(container_repository)
        return false unless can?(current_user, :admin_container_image, project)

        # TODO
      end
    end
  end
end
