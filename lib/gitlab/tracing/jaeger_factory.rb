# frozen_string_literal: true

require 'jaeger/client'
require 'jaeger/client/http_sender'

module Gitlab
  module Tracing
    module JaegerFactory
      DEFAULT_PROBABILISTIC_RATE = 0.001
      DEFAULT_UDP_PORT = 6831

      def self.create_tracer(service_name, options)
        defaults = {
          service_name: service_name,
          # Reduce this from default of 10 seconds as the Ruby jaeger
          # client doesn't have overflow control, leading to very large
          # messages which fail to send over UDP (max packet = 64k)
          # Flush more often, with smaller packets
          flush_interval: 5
        }

        jaeger_kwargs = configure(options, defaults, {
          debug: -> (v, kwargs)         {  },             # Ignore in ruby for now
          sampler: -> (v, kwargs)       { kwargs[:sampler] = get_sampler(v, options["sampler_param"]) },
          sampler_param: -> (v, kwargs) {  },             # Consumed in `sampler`
          http_endpoint: -> (v, kwargs) { kwargs[:sender] = get_http_sender(service_name, v) },
          udp_endpoint: -> (v, kwargs)  { kwargs[:sender] = get_udp_sender(service_name, v) }
        })

        Jaeger::Client.build(jaeger_kwargs)
      end

      def self.configure(options, defaults, configurers)
        kwargs = defaults.clone

        options.each do |k, v|
          configurer = configurers[k.to_sym]
          next if k == "strict_parsing"

          unless configurer
            if options["strict_parsing"]
              raise "jaeger tracer: invalid option: #{k}"
            end

            warn "jaeger tracer: invalid option: #{k}"
            next
          end

          configurer.call(v, kwargs)
        end

        kwargs
      end
      private_class_method :configure

      def self.get_sampler(sampler_type, sampler_param)
        case sampler_type
        when "probabilistic"
          sampler_rate = sampler_param ? sampler_param.to_f : DEFAULT_PROBABILISTIC_RATE
          Jaeger::Client::Samplers::Probabilistic.new(sampler_rate)
        when "const"
          const_value = sampler_param == "1"
          Jaeger::Client::Samplers::Const.new(const_value)
        else
          nil
        end
      end
      private_class_method :get_sampler

      def self.get_http_sender(service_name, address)
        encoder = Jaeger::Client::Encoders::ThriftEncoder.new(service_name: service_name)

        Jaeger::Client::HttpSender.new(
          url: address,
          encoder: encoder,
          logger: Logger.new(STDOUT)
        )
      end
      private_class_method :get_http_sender

      def self.udp_endpoint(service_name, address)
        pair = address.split(":", 2)
        host = pair[0]
        port = pair[1] ? pair[1].to_i : DEFAULT_UDP_PORT

        encoder = Jaeger::Client::Encoders::ThriftEncoder.new(service_name: service_name)

        Jaeger::Client::UdpSender.new(
          host: host,
          port: port,
          encoder: encoder,
          logger: Logger.new(STDOUT)
        )
      end
      private_class_method :udp_endpoint
    end
  end
end
