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
        if profile?(env)
          call_with_profiling(env)
        else
          @app.call(env)
        end
      end

      def profile?(env)
        header_token = env['HTTP_X_PROFILE_TOKEN']
        return unless header_token.present?

        profile_token = Gitlab::RequestProfiler.profile_token
        return unless profile_token.present?

        header_token == profile_token
      end

      def call_with_profiling(env)
        case env['HTTP_X_PROFILE_MODE'] 
        when 'execution'
          call_with_call_stack_profiling(env)
        when 'memory'
          call_with_memory_profiling(env)
        else
        end
      end

      def call_with_call_stack_profiling(env)
        request_ret, profile_ret = handle_request(RubyProf::Profile.profile, env)

        generate_report do |file_path|
          printer   = RubyProf::CallStackPrinter.new(profile_ret)
          File.open(file_path, 'wb') do |file|
            printer.print(file_path)
          end
        end

        handle_request_ret(request_ret)
      end

      def call_with_memory_profiling(env)
        request_ret, profile_ret = handle_request(MemoryProfiler.report, env)

        generate_report do |file_path|
          report.pretty_print(to_file: file_path)
          prepend_pre_to_file_content(file_path)
        end

        handle_request_ret(request_ret)
      end

      def handle_request(profiler, env)
        request_ret = nil
        profile_ret = profiler do
          request_ret = catch(:warden) do
            @app.call(env)
          end
        end
        return request_ret, profile_ret
      end

      def generate_report
        file_name = "#{env['PATH_INFO'].tr('/', '|')}_#{Time.current.to_i}.html"
        file_path = "#{PROFILES_DIR}/#{file_name}"

        FileUtils.mkdir_p(PROFILES_DIR)

        yield(file_path)
      end

      def handle_request_ret(request_ret)
        if request_ret.is_a?(Array)
          request_ret
        else
          throw(:warden, request_ret)
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

    end
  end
end
