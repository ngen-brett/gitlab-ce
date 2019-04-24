# frozen_string_literal: true

module Gitlab
  module LetsEncrypt
    PRODUCTION_DIRECTORY_URL = 'https://acme-v02.api.letsencrypt.org/directory'
    STAGING_DIRECTORY_URL = 'https://acme-staging-v02.api.letsencrypt.org/directory'

    class << self
      def client
        raise 'Acme integration is disabled' unless acme_integration_enabled?

        acme_client = ::Acme::Client.new(private_key: private_key,
                                         directory: directory)

        # does nothing if account is already registered
        acme_client.new_account(contact: contact, terms_of_service_agreed: true)

        acme_client
      end

      def terms_of_service_url
        ::Acme::Client.new(directory: directory).terms_of_service
      end

      def enabled?
        return false unless Feature.enabled?(:pages_auto_ssl)

        application_settings = Gitlab::CurrentSettings.current_application_settings

        application_settings.acme_terms_of_service_accepted && admin_email
      end

      private

      def private_key
        Gitlab::Application.secrets.lets_encrypt_private_key
      end

      def admin_email
        ApplicationSetting.current.acme_notification_email
      end

      def contact
        "mailto:#{admin_email}"
      end

      def directory
        if Rails.env.production?
          PRODUCTION_DIRECTORY_URL
        else
          STAGING_DIRECTORY_URL
        end
      end
    end
  end
end
