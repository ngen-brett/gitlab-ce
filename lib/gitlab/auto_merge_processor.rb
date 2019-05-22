# frozen_string_literal: true

module Gitlab
  class AutoMergeProcessor
    class << self
      def available_strategies
        %i[merge_when_pipeline_succeeds]
      end
    end

    attr_reader :project, :user

    def initialize(project, user)
      @project = project
      @user = user
    end

    def execute(merge_request, strategy)
      self.fabricate!(strategy).execute(merge_request)
    end

    def cancellable?(merge_request, user)
      available_strategies.any? do |strategy|
        self.fabricate!(strategy).cancellable?(merge_request, user)
      end
    end

    def cancel(merge_request, user)
      available_strategies.each do |strategy|
        self.fabricate!(strategy).cancel(merge_request, user)
      end
    end

    private

    def fabricate!(strategy: :merge_when_pipeline_succeeds)
      const_get("GitLab::AutoMergeStrategy::#{strategy}").new(project, user)
    end
  end
end
