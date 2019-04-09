# frozen_string_literal: true

module Ci
  class PlayManualBuildsService < BaseService
    def execute(pipeline, stage)
      @pipeline = pipeline
      @stage = stage

      manual_builds.each do |build|
        build.play(current_user) if build.playable?
      end
    end

    private

    attr_reader :pipeline, :stage

    def manual_builds
      @manual_builds ||= stage.builds.manual
    end
  end
end
