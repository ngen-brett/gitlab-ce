# frozen_string_literal: true

module Projects
  module ErrorTracking
    class SettingService < BaseService
      def execute
        ::ErrorTracking::ErrorTrackingSetting.create_or_update(project, params)
        success
      rescue ActiveRecord::RecordInvalid => e
        error(message_from(e.record))
      end

      private

      def message_from(setting)
        setting.errors.full_messages.to_sentence
      end
    end
  end
end
