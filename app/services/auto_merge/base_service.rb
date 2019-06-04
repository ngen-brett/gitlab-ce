# frozen_string_literal: true

module AutoMerge
  class BaseService < ::BaseService
    include Gitlab::Utils::StrongMemoize

    def execute(merge_request)
      merge_request.merge_params.merge!(params)
      merge_request.auto_merge_enabled = true
      merge_request.merge_user = current_user
      merge_request.auto_merge_strategy = strategy

      return :failed unless merge_request.save

      yield if block_given?

      strategy.to_sym
    end

    def cancel(merge_request)
      if cancel_auto_merge(merge_request)
        yield if block_given?

        success
      else
        error("Can't cancel the automatic merge", 406)
      end
    end

    def strategy
      strong_memoize(:strategy) do
        class_name = self.class.name.split('::').last.slice('Service')
        class_name.underscore
      end
    end

    private

    def cancel_auto_merge(merge_request)
      merge_request.auto_merge_enabled = false
      merge_request.merge_user = nil

      if merge_request.merge_params
        merge_request.merge_params.delete('should_remove_source_branch')
        merge_request.merge_params.delete('commit_message')
        merge_request.merge_params.delete('squash_commit_message')
        merge_request.merge_params.delete('auto_merge_strategy')
      end

      merge_request.save
    end
  end
end
