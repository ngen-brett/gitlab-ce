# frozen_string_literal: true

module Gitlab
  module Auth
    class UserAccessDeniedReason
      def initialize(user)
        @user = user
      end

      def rejection_message
        case rejection_type
        when :internal
          "This action cannot be performed by internal users"
        when :terms_not_accepted
          "You (#{@user.to_reference}) must accept the Terms of Service in order to perform this action. "\
          "Please access GitLab from a web browser to accept these terms."
        when :deactivated
          "Your account has been deactivated due to more than #{::User::MINIMUM_INACTIVE_DAYS} days of inactivity. "\
          "Please log in to GitLab from a web browser to to activate your account."
        else
          "Your account has been blocked."
        end
      end

      private

      def rejection_type
        if @user.internal?
          :internal
        elsif @user.required_terms_not_accepted?
          :terms_not_accepted
        elsif @user.deactivated?
          :deactivated
        else
          :blocked
        end
      end
    end
  end
end
