# frozen_string_literal: true

class PipelineProcessWorker
  include ApplicationWorker
  include PipelineQueue
  include Deduplicater

  queue_namespace :pipeline_processing

  def perform(pipeline_id)
    Ci::Pipeline.find_by_id(pipeline_id).try(:process!)
  end
end
