# frozen_string_literal: true

module Gitlab
  module Tracing
    module Rails
      module RailsCommon
        include Gitlab::Tracing::Common

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def create_unsubscriber(subscriptions)
            -> { subscriptions.each { |subscriber| ActiveSupport::Notifications.unsubscribe(subscriber) } }
          end
        end
      end
    end
  end
end
