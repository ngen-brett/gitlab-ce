# frozen_string_literal: true

module MergeTrain
  class ProcessMergeTrainsWorker
    include ApplicationWorker

    def perform(project_id, ref)
      project = Project.find_by(id: project_id)
      return unless project
      
      MergeTrain::ProcessMergeTrainsService.new(
        project, ref).execute
    end
  end
end
