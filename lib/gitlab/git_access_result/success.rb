# frozen_string_literal: true

module Gitlab
  module GitAccessResult
    class Success
      attr_reader :message

      def initialize(message = nil)
        @message = message
      end
    end
  end
end
