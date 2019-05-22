# frozen_string_literal: true

module Gitlab
  class AutoMergeStrategy
    class Base
      attr_reader :project, :user

      def initialize(project, user)
        @project = project
        @user = user
      end
    end
  end
end
