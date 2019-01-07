# frozen_string_literal: true

module Gitlab
  module Tracing
    class SidekiqClientMiddleware
      include Common

      def call(worker_class, job, queue, redis_pool)
        tracer = OpenTracing.global_tracer

        start_active_span(
          operation_name: job['class'],
          tags: tags_from_job(job, 'client')) do |span|
          # Inject the details directly into the job
          tracer.inject(span.context, OpenTracing::FORMAT_TEXT_MAP, job)
          yield
        end
      end
    end
  end
end
