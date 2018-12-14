# frozen_string_literal: true

require "cgi"

module Gitlab
  module Tracing
    module Factory
      def self.create_tracer
        tracing_connection = ENV['GITLAB_TRACING']
        return nil unless tracing_connection

        begin
          opentracing_details = parse_connection_string(tracing_connection)

          case opentracing_details[:driver_name]
          when "jaeger"
            Gitlab::Tracing::JaegerFactory.create_tracer(opentracing_details[:options])
          # Add additional drivers here....
          else
            nil
          end
        rescue
          # Can't create the tracer? Then we don't use a tracer.
          nil
        end
      end

      private

      def self.parse_connection_string(connection_string)
        parsed = URI.parse(connection_string)

        if parsed.scheme != "opentracing" || !parsed.host || parsed.path != "" || /^[a-z0-9_]+$/ !~ parsed.host
          raise "Invalid tracing connection string"
        end

        if parsed.query
          options = Hash[CGI::parse(parsed.query).map{|k,v| [k, v.first]}]
        else
          options = Hash.new
        end

        return {
          driver_name: parsed.host,
          options: options
        }
      end
    end
  end
end
