# frozen_string_literal: true

require "cgi"

module Gitlab
  module Tracing
    class Factory
      def self.create_tracer(service_name, connection_string)
        return nil unless connection_string && !connection_string.empty?

        begin
          opentracing_details = parse_connection_string(connection_string)

          case opentracing_details[:driver_name]
          when "jaeger"
            JaegerFactory.create_tracer(service_name, opentracing_details[:options])
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
                    Hash[CGI.parse(parsed.query).map { |k, v| [k.to_sym, v.first] }]
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
