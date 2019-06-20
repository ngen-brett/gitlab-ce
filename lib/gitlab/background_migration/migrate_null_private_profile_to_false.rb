# frozen_string_literal: true
# rubocop:disable Style/Documentation

module Gitlab
  module BackgroundMigration
    class MigrateNullPrivateProfileToFalse
      BATCH_SIZE = 1_000

      class User < ActiveRecord::Base
        self.table_name = 'users'

        include ::EachBatch
      end

      def perform
        User.where(private_profile: nil).each_batch do |batch|
          batch.update_all(private_profile: false)
        end
      end
    end
  end
end

