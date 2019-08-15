# frozen_string_literal: true

module Prometheus
  module CleanupMultiprocDir
    def self.call
      if dir = ::Prometheus::Client.configuration.multiprocess_files_dir
        old_metrics = Dir[File.join(dir, '*.db')]

        FileUtils.rm_rf(old_metrics)
      end
    end
  end
end
