# frozen_string_literal: true

class AnalyticsStageEntity < Grape::Entity
  include EntityDateHelper

  expose :title
  expose :name
  expose :legend
  expose :description

  expose :median, as: :value do |stage|
    puts stage.median
    # median returns a BatchLoader instance which we first have to unwrap by using to_f
    !stage.median.to_f.zero? ? distance_of_time_in_words(stage.median) : nil
  end
end
