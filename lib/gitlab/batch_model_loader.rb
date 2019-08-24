# frozen_string_literal: true

module Gitlab
  class BatchModelLoader
    attr_reader :model_class, :model_id

    def initialize(model_class, model_id)
      @model_class, @model_id = model_class, model_id
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def find
      BatchLoader.for(ModelInfo.new(model_class, model_id.to_i)).batch do |infos, loader|
        ids_by_model(infos).each do |model, ids|
          model.where(id: ids).each { |record| loader.call(ModelInfo.new(model, record.id), record) }
        end
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord

    private

    ModelInfo = Struct.new(:model, :id)

    def ids_by_model(infos)
      infos.reduce({}) { |acc, info| merge_sum(acc, info.model => [info.id]) }
    end

    def merge_sum(a_hash, another_hash)
      a_hash.merge(another_hash) { |_, a, b| a + b }
    end
  end
end
