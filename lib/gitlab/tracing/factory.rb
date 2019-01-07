# frozen_string_literal: true

require "cgi"

module Gitlab
  module Tracing
    module Factory
      def self.create_tracer(service_name)
        tracing_connection = ENV['GITLAB_TRACING']
        return nil unless tracing_connection

        begin
          opentracing_details = parse_connection_string(tracing_connection)

          case opentracing_details[:driver_name]
          when "jaeger"
            Gitlab::Tracing::JaegerFactory.create_tracer(service_name, opentracing_details[:options])
          else
            nil
          end
        rescue => e
          # Can't create the tracer? Warn and continue sans tracer
          warn "Unable to instantiate tracer: #{e}"
          nil
        end
      end

      def self.parse_connection_string(connection_string)
        parsed = URI.parse(connection_string)

        if parsed.scheme != "opentracing" || !parsed.host || parsed.path != "" || /^[a-z0-9_]+$/ !~ parsed.host
          raise "Invalid tracing connection string"
        end

        options = if parsed.query
                    Hash[CGI.parse(parsed.query).map { |k, v| [k, v.first] }]
                  else
                    {}
                  end

        {
          driver_name: parsed.host,
          options: options
        }
      end
      private_class_method :parse_connection_string
    end
  end
end
