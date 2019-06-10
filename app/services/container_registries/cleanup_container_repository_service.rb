# frozen_string_literal: true

module ContainerRegistries
  class CleanupContainerRepositoryService
    include ExclusiveLeaseGuard

    LEASE_TIMEOUT = 1.hour

    attr_reader :message, :repository, :current_user, :params

    def initialize(current_user, repository, params)
      @current_user = current_user
      @repository = repository
      @params = params
    end

    def execute
      try_obtain_lease do
        CleanupContainerRepositoryWorker.perform_async(current_user.id, repository.id,
          params)

        return true # rubocop: disable Cop/AvoidReturnFromBlocks
      end
      @message = 'This request has already been made. You can run this at most once an hour for a given container repository'
      false
    end

    private

    # For ExclusiveLeaseGuard concern
    def lease_key
      @lease_key ||= "container_repository:cleanup_tags:#{repository.id}"
    end

    # For ExclusiveLeaseGuard concern
    def lease_timeout
      LEASE_TIMEOUT
    end

    # For ExclusiveLeaseGuard concern
    def lease_release?
      # we don't allow to execute this service
      # more often than LEASE_TIMEOUT
      # for given container repository
      false
    end
  end
end
