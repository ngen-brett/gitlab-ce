module MergeTrain
  class ProcessMergeTrainsService
    include ::Gitlab::ExclusiveLeaseHelpers

    attr_reader :project, :ref

    MAX_PARALLEL_IN_TRAIN = 1

    def initalize(project, ref)
      @project, @ref = project, ref
    end

    def execute
      in_lock(lock_key) do
        all_in_train.find_each do |merge_train|
          # TODO: it costs one additional query, up to MAX_PARALLEL_IN_TRAIN
          break if merge_train.index > MAX_PARALLEL_IN_TRAIN

          ProcessMergeTrainService.new(merge_train)
            .execute
        end
      end
    end

    private

    def all_in_train
      MergeTrain.where(merge_request: 
        MergeRequest.where(target_project: project, target_branch: ref))
        .ordered
    end

    def lock_key
      "merge_train:#{project.id}-#{ref}"
    end
  end
end
