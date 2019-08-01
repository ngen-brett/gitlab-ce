# frozen_string_literal: true

##
# Deduplicating redandant sidekiq jobs with BatchPopQueueing.
module Deduplicater
  extend ActiveSupport::Concern
  extend ::Gitlab::Utils::Override

  included do
    class_attribute :deduplicater_default_enabled
    class_attribute :deduplicater_lock_timeout

    # The deduplicater is behind a feature flag and you can disable the behavior
    # by disabling the feature flag.
    # The deduplicater is enabled by default, if you want to disable by default,
    # set `false` to the `deduplicater_default_enabled` vaule.
    self.deduplicater_default_enabled = true

    # The deduplicater runs the process in an exclusive lock and while the lock
    # is effective the duplicate sidekiq jobs will be absorbed or defered after
    # the current process has done.
    # Basically, you should set `deduplicater_lock_timeout` a grater vaule than
    # the maximum execution time of the process.
    self.deduplicater_lock_timeout = 10.minutes
  end

  override :perform
  def perform(arg)
    if Feature.enabled?(feature_flag_name, default_enabled: deduplicater_default_enabled)
      result = Gitlab::BatchPopQueueing.new(sanitized_worker_name, arg.to_s)
                                       .safe_execute([arg], lock_timeout: deduplicater_lock_timeout) do |items|
        super(items.first)
      end

      if result[:status] == :finished && result[:new_items].present?
        self.class.perform_async(result[:new_items].first)
      end
    else
      super(arg)
    end
  end

  private

  def sanitized_worker_name
    self.class.name.underscore
  end

  def feature_flag_name
    "enable_deduplicater_for_#{sanitized_worker_name}"
  end
end
