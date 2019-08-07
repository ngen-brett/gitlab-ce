# frozen_string_literal: true

module API
  module Support
    class Actor
      attr_reader :obj

      def initialize(obj)
        @obj = obj
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def self.from_params(params)
        if params[:key_id]
          Key.find_by(id: params[:key_id])
        elsif params[:user_id]
          User.find_by(id: params[:user_id])
        elsif params[:username]
          UserFinder.new(params[:username]).find_by_username
        end
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def user
        obj.is_a?(Key) ? obj.user : obj
      end

      def username
        user&.username
      end

      def update_last_used_at!
        obj.update_last_used_at if obj.is_a?(Key)
      end
    end
  end
end
