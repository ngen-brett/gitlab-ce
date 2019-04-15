# frozen_string_literal: true

module Ci
  class PrepareBuildService
    attr_reader :build

    def initialize(build)
      @build = build
    end

    def execute
      prerequisites.each(&:complete!)

      build.enqueue!
    rescue => e
      # Prerequisites provide their own logging for specific error classes
      Rails.logger.error("Unable to complete prerequisites for build #{build.id}")

      build.drop(:unmet_prerequisites)
    end

    private

    def prerequisites
      build.prerequisites
    end
  end
end
