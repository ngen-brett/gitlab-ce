# frozen_string_literal: true

class BatchPopQueueingWorker
  include ApplicationWorker

  def perform(namespace, class_name, ttl)
    return unless Feature.enabled?(:batch_pop_queueing)

    Gitlab::BatchPopQueueing.safe_execute(namespace, class_name, nil, ttl)
  end
end
