# frozen_string_literal: true

module Gitlab
  ##
  # This class is a queuing system for processing expensive tasks in an atomic manner
  # with batch poping to let you optimize the total processing time.
  #
  # In usual queuing system, the first item started being processed immediately
  # and the following items wait for the next items have been poped from the queue.
  # On the other hand, this queueing system, the former part is same, however,
  # it pops the enqueued items as batch. This is especially useful when you want to
  # drop redandant items from the queue in order to process important items only,
  # thus it's more efficient than the traditional ququeing system.
  class BatchPopQueueing
    class << self
      ##
      # Arguments:
      # - namespace ... The namespace of the queue
      # - class_name ... The class name which has expensive task.
      # - new_item ... New ieam to be pushed to a queue or processed immediately.
      # - ttl ... TTL of the exclusive lease. Usually you set a bigger value than the maximum timing of the expensive task.
      #
      # Call Backs:
      # - self.batch_pop(queues) ... It's invoked when the current thread or BatchPopQueueingWorker processes the expensive task.
      def safe_execute(namespace, class_name, new_item, ttl)
        raise ArgumentError unless namespace && class_name

        lock_key = lock_key(namespace)
        queue_key = queue_key(namespace)
        lease = Gitlab::ExclusiveLease.new(lock_key, timeout: ttl)

        unless uuid = lease.try_obtain
          if new_item
            ##
            # There is a on-going process thus push the current item to the queue
            # and exit the current thread immediately.
            enqueue(queue_key, new_item)
            return :enqueued
          else
            ##
            # There is a on-going process and this thread is performed by BatchPopQueueingWorker.
            # The other locking thread will invoke new BatchPopQueueingWorker later,
            # so that it's safe to ignore this thread.
            return :ignored
          end
        end

        begin
          all_args = (pop_all(queue_key) + [new_item]).compact
          class_name.constantize.batch_pop(all_args)
        ensure
          Gitlab::ExclusiveLease.cancel(lock_key, uuid) if uuid
        end

        # If we have anything added new to the queue during the current thread,
        # BatchPopQueueingWorker will continue working on the queue asynchronously.
        if anything_in_queue?(queue_key)
          BatchPopQueueingWorker.perform_async(namespace, class_name, ttl)
          return :continued
        end

        :finished
      end

      private

      def lock_key(namespace)
        "batch_pop_queueing:lock:#{namespace}"
      end

      def queue_key(namespace)
        "batch_pop_queueing:queue:#{namespace}"
      end

      def enqueue(queue_key, element)
        Gitlab::Redis::Queues.with do |redis|
          redis.rpush(queue_key, element)
        end
      end

      def pop_all(queue_key)
        Gitlab::Redis::Queues.with do |redis|
          redis.lrange(queue_key, 0, -1).tap do |elements|
            redis.del(queue_key)
          end
        end
      end

      def anything_in_queue?(queue_key)
        Gitlab::Redis::Queues.with do |redis|
          redis.llen(queue_key) > 0
        end
      end
    end
  end
end
