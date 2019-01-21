# frozen_string_literal: true

class MergeRequestWidgetCommitEntity < Grape::Entity
  expose :safe_message, as: :message
  expose :short_id, as: :sha
  expose :title
end
