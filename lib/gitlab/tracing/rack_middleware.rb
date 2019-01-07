# frozen_string_literal: true

require 'opentracing'

module Gitlab
  module Tracing
    class RackMiddleware
      include Common

      REQUEST_URI = 'REQUEST_URI'.freeze
      REQUEST_METHOD = 'REQUEST_METHOD'.freeze

      def initialize(app)
        @app = app
      end

      def call(env)
        tracer = OpenTracing.global_tracer
        method = env[REQUEST_METHOD]

        context = tracer.extract(OpenTracing::FORMAT_RACK, env)
        start_active_span(
          operation_name: method,
          child_of:       context,
          tags: {
            'component' => 'rack',
            'span.kind' => 'server',
            'http.method' => method,
            'http.url' => env[REQUEST_URI]
          }) do |span|
          @app.call(env).tap do |status_code, _headers, _body|
            span.set_tag('http.status_code', status_code)
          end
        end
      end
    end
  end
end
