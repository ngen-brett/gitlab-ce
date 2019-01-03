# frozen_string_literal: true

module Operations
  class FeatureFlag < ActiveRecord::Base
    self.table_name = 'operations_feature_flags'

    belongs_to :project

    validates :project, presence: true
    validates :name,
      presence: true,
      length: 2..63,
      format: {
        with: Gitlab::Regex.feature_flag_regex,
        message: Gitlab::Regex.feature_flag_regex_message
      }
    validates :name, uniqueness: { scope: :project_id }
    validates :description, allow_blank: true, length: 0..255

    scope :ordered, -> { order(:name) }
    scope :enabled, -> { where(active: true) }
    scope :disabled, -> { where(active: false) }

    def strategies
      [
        { name: 'default' }
      ]
    end
  end
end
