# frozen_string_literal: true

module Gitlab
  module Tracing
    module Rails
      class ActionViewSubscriber
        include RailsCommon

        RENDER_TEMPLATE_NOTIFICATION_TOPIC = 'render_template.action_view'
        RENDER_COLLECTION_NOTIFICATION_TOPIC = 'render_collection.action_view'
        RENDER_PARTIAL_NOTIFICATION_TOPIC = 'render_partial.action_view'

        # Instruments Rails ActionView events for opentracing.
        # Returns a lambda, which, when called will unsubscribe from the notifications
        def self.instrument
          subscriber = new

          subscriptions = [
            ActiveSupport::Notifications.subscribe(RENDER_TEMPLATE_NOTIFICATION_TOPIC) do |_, start, finish, _, payload|
              subscriber.notify_render_template(start, finish, payload)
            end,
            ActiveSupport::Notifications.subscribe(RENDER_COLLECTION_NOTIFICATION_TOPIC) do |_, start, finish, _, payload|
              subscriber.notify_render_collection(start, finish, payload)
            end,
            ActiveSupport::Notifications.subscribe(RENDER_PARTIAL_NOTIFICATION_TOPIC) do |_, start, finish, _, payload|
              subscriber.notify_render_partial(start, finish, payload)
            end
          ]

          create_unsubscriber subscriptions
        end

        # For more information on the payloads: https://guides.rubyonrails.org/active_support_instrumentation.html
        def notify_render_template(start, finish, payload)
          exception = payload[:exception]
          tags = {
            'component' =>       'ActionView',
            'span.kind' =>       'client',
            'template.id' =>     payload[:identifier],
            'template.layout' => payload[:layout]
          }

          postnotify_span("render_template", start, finish, tags: tags, exception: exception)
        end

        def notify_render_collection(start, finish, payload)
          exception = payload[:exception]
          tags = {
            'component' =>            'ActionView',
            'span.kind' =>            'client',
            'template.id' =>          payload[:identifier],
            'template.count' =>       payload[:count] || 0,
            'template.cache.hits' =>  payload[:cache_hits] || 0
          }

          postnotify_span("render_collection", start, finish, tags: tags, exception: exception)
        end

        def notify_render_partial(start, finish, payload)
          exception = payload[:exception]
          tags = {
            'component' =>            'ActionView',
            'span.kind' =>            'client',
            'template.id' =>          payload[:identifier]
          }

          postnotify_span("render_partial", start, finish, tags: tags, exception: exception)
        end
      end
    end
  end
end
