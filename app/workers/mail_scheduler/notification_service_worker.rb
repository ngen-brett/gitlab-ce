# frozen_string_literal: true

require 'active_job/arguments'

module MailScheduler
  class NotificationServiceWorker
    include ApplicationWorker
    include MailSchedulerQueue

    def perform(meth, *args)
      return if args_not_deserializable?(args)

      deserialized_args = ActiveJob::Arguments.deserialize(args)
      notification_service.public_send(meth, *deserialized_args) # rubocop:disable GitlabSecurity/PublicSend
    end

    def self.perform_async(*args)
      super(*ActiveJob::Arguments.serialize(args))
    end

    private

    # Until Rails 4.2.11 / 5.0.7.1 if an argument could not be deserialized,
    # the `ActiveJob::DeserializationError` exception was raised.
    # Starting from the versions mentioned above no exceptions are raised anymore if an argument
    # cannot be deserialized. Such arguments just get returned back as-is.
    # See CVE-2018-16476 (https://groups.google.com/forum/#!topic/rubyonrails-security/FL4dSdzr2zw)
    # This methods explicitly checks if passed arguments can be deserialized before
    # calling any public methods of NotificationService.
    def args_not_deserializable?(args)
      args.any? { |arg| arg.class.in?(ActiveJob::Arguments::TYPE_WHITELIST) }
    end
  end
end
