# frozen_string_literal: true

module Gitlab
  module Tracing
    class SidekiqServerMiddleware
      include Common

      def call(worker, job, queue)
        tracer = OpenTracing.global_tracer

        context = tracer.extract(OpenTracing::FORMAT_TEXT_MAP, job)

        start_active_span(
          operation_name: job['class'],
          child_of: context,
          tags: tags_from_job(job, 'server')) do |span|
          yield
        end
      end
    end
  end
end
