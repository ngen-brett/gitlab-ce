# frozen_string_literal: true

require 'jaeger/client'

module Gitlab
  module Tracing
    module JaegerFactory
      def self.create_tracer(options)
        Jaeger::Client.build(service_name: 'unicorn')
      end
    end
  end
end
