# frozen_string_literal: true

module Gitlab
  class JsonLogger < ::Gitlab::Logger
    def self.file_name_noext
      raise NotImplementedError
    end

    def format_message(severity, timestamp, progname, message)
      data = {}
      data[:severity] = severity
      data[:time] = timestamp.utc.iso8601(3)
      data[Gitlab::CorrelationId::LOG_KEY] = Gitlab::CorrelationId.current_id

      case message
      when String
        data[:message] = message
      when Hash
        data.merge!(message)
      end

      data.to_json + "\n"
    end
  end
end
