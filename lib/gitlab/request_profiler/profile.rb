# frozen_string_literal: true

module Gitlab
  module RequestProfiler
    class Profile
      attr_reader :name, :time, :request_path, :type

      alias_method :to_param, :name

      def self.all
        Dir["#{PROFILES_DIR}/*.{html,txt}"].map do |path|
          new(File.basename(path))
        end
      end

      def self.find(name)
        raise "missing extension: #{name}" unless (name.end_with?('.html') || name.end_with?('.txt'))

        file_path = "#{PROFILES_DIR}/#{name}"
        return unless File.exist?(file_path)

        new(name)
      end

      def initialize(name)
        @name = name

        set_attributes
      end

      def content
        File.read("#{PROFILES_DIR}/#{name}")
      end

      private

      def set_attributes
        _, path, timestamp, type = name.split(/(.*)_(\d+)_(.*)\.(html|txt)$/)
        @request_path            = path.tr('|', '/')
        @time                    = Time.at(timestamp.to_i).utc
        @type                    = type
      end
    end
  end
end
