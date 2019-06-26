module Importers
  module CommonMetrics
  end

  # Patch to preserve old CommonMetricsImporter api
  module CommonMetricsImporter
    def self.new(*args)
      Importers::CommonMetrics::Importer.new(*args)
    end
  end
end
