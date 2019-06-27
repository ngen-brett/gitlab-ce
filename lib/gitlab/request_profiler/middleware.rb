# frozen_string_literal: true

require 'ruby-prof'
require 'memory_profiler'

module Gitlab
  module RequestProfiler
    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        if profile_execution?(env)
          call_with_profiling_execution(env)
        elsif profile_memory?(env)
          call_with_profiling_memory(env)
        else
          @app.call(env)
        end
      end

      def valid_profile_token?(env)
        header_token = env['HTTP_X_PROFILE_TOKEN']
        return unless header_token.present?

        profile_token = Gitlab::RequestProfiler.profile_token
        return unless profile_token.present?

        header_token == profile_token
      end

      def profile_execution?(env)
        return unless valid_profile_token?(env)

        profile_mode = env['HTTP_X_PROFILE_MODE']
        return unless profile_mode.present?

        profile_mode == 'execution'
      end

      def profile_memory?(env)
        return unless valid_profile_token?(env)

        profile_mode = env['HTTP_X_PROFILE_MODE']
        return unless profile_mode.present?

        profile_mode == 'memory'
      end

      def call_with_profiling_execution(env)
        ret = nil
        result = RubyProf::Profile.profile do
          ret = catch(:warden) do
            @app.call(env)
          end
        end

        printer   = RubyProf::CallStackPrinter.new(result)
        file_name = "#{env['PATH_INFO'].tr('/', '|')}_#{Time.current.to_i}.html"
        file_path = "#{PROFILES_DIR}/#{file_name}"

        FileUtils.mkdir_p(PROFILES_DIR)
        File.open(file_path, 'wb') do |file|
          printer.print(file)
        end

        if ret.is_a?(Array)
          ret
        else
          throw(:warden, ret)
        end
      end

      def prepend_pre_to_file_content(file_path)
        new_file = "#{file_path}_new_temp"
        File.open(new_file, 'w') do |fo|
          fo.puts '<pre>'
          File.foreach(file_path) do |li|
            fo.puts li
          end
        end
        File.rename(new_file, file_path)
      end

      def call_with_profiling_memory(env)
        ret = nil
        report = MemoryProfiler.report do
          ret = catch(:warden) do
            @app.call(env)
          end
        end

        file_name = "#{env['PATH_INFO'].tr('/', '|')}_#{Time.current.to_i}.html"
        file_path = "#{PROFILES_DIR}/#{file_name}"

        FileUtils.mkdir_p(PROFILES_DIR)

        report.pretty_print(to_file: file_path)

        prepend_pre_to_file_content(file_path)

        if ret.is_a?(Array)
          ret
        else
          throw(:warden, ret)
        end
      end
    end
  end
end
