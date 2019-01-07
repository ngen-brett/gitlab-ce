# frozen_string_literal: true

require 'jaeger/client'

module Gitlab
  module Tracing
    class JaegerFactory
      # When the probabilistic sampler is used, by default 0.1% of requests will be traced
      DEFAULT_PROBABILISTIC_RATE = 0.001

      # The default port for the Jaeger agent UDP listener
      DEFAULT_UDP_PORT = 6831

      # Reduce this from default of 10 seconds as the Ruby jaeger
      # client doesn't have overflow control, leading to very large
      # messages which fail to send over UDP (max packet = 64k)
      # Flush more often, with smaller packets
      FLUSH_INTERVAL = 5

      def self.create_tracer(service_name, options)
        defaults = {
          service_name: service_name
        }

        jaeger_kwargs = configure(options, defaults, {
          debug: -> (v, kwargs)         {  },             # Ignore in ruby for now
          sampler: -> (v, kwargs)       { kwargs[:sampler] = get_sampler(v, options[:sampler_param]) },
          sampler_param: -> (v, kwargs) {  },             # Consumed in `sampler`
          http_endpoint: -> (v, kwargs) { kwargs[:reporter] = JaegerFactory.get_http_sender(service_name, v) },
          udp_endpoint: -> (v, kwargs)  { kwargs[:reporter] = JaegerFactory.get_udp_sender(service_name, v) }
        })

        Jaeger::Client.build(jaeger_kwargs)
      end

      def self.configure(options, defaults, configurers)
        kwargs = defaults.clone

        options.each do |k, v|
          configurer = configurers[k.to_sym]
          next if k == :strict_parsing

          unless configurer
            if options[:strict_parsing]
              raise "jaeger tracer: invalid option: #{k}"
            end

            warn "jaeger tracer: invalid option: #{k}"
            next
          end

          configurer.call(v, kwargs)
        end

        kwargs
      end
      # private_class_method :configure

      def self.get_sampler(sampler_type, sampler_param)
        case sampler_type
        when "probabilistic"
          sampler_rate = sampler_param ? sampler_param.to_f : DEFAULT_PROBABILISTIC_RATE
          Jaeger::Samplers::Probabilistic.new(rate: sampler_rate)
        when "const"
          const_value = sampler_param == "1"
          Jaeger::Samplers::Const.new(const_value)
        else
          nil
        end
      end

      def self.get_http_sender(service_name, address)
        encoder = Jaeger::Encoders::ThriftEncoder.new(service_name: service_name)

        Jaeger::Reporters::RemoteReporter.new(
          sender: Jaeger::HttpSender.new(
            url: address,
            encoder: encoder,
            logger: Logger.new(STDOUT)
          ),
          flush_interval: FLUSH_INTERVAL
        )
      end

      def self.get_udp_sender(service_name, address)
        pair = address.split(":", 2)
        host = pair[0]
        port = pair[1] ? pair[1].to_i : DEFAULT_UDP_PORT

        encoder = Jaeger::Encoders::ThriftEncoder.new(service_name: service_name)

        Jaeger::Reporters::RemoteReporter.new(
          sender: Jaeger::UdpSender.new(
            host: host,
            port: port,
            encoder: encoder,
            logger: Logger.new(STDOUT)
          ),
          flush_interval: FLUSH_INTERVAL
        )
      end
    end
  end
end
