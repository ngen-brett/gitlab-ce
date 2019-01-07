# frozen_string_literal: true

class UserPreference < ActiveRecord::Base
  # We could use enums, but Rails 4 doesn't support multiple
  # enum options with same name for multiple fields, also it creates
  # extra methods that aren't really needed here.
  NOTES_FILTERS = { all_notes: 0, only_comments: 1, only_activity: 2 }.freeze
  SORT_BY = {
    priority: 0,
    created_date: 1,
    created_asc: 2,
    updated_desc: 3,
    updated_asc: 4,
    milestone: 5,
    milestone_due_desc: 6,
    popularity: 7,
    label_priority: 8,
    due_date: 9 # issues only
  }.freeze

  belongs_to :user

  validates :issue_notes_filter, :merge_request_notes_filter, inclusion: { in: NOTES_FILTERS.values }, presence: true
  validates :issue_sort_by, :merge_request_sort_by, inclusion: { in: SORT_BY.values }, allow_nil: true

  [:issue, :merge_request].each do |type|
    attr = :"#{type}_sort_by"

    define_method "#{attr}_field" do
      # Return the key that matches the DB value as a string
      # By using the safe navigator we ensure that `nil.to_s` returns `nil` instead of an empty string `""`
      val = self[attr]
      SORT_BY.key(val)&.to_s
    end

    define_method "#{attr}_field=" do |val|
      self[attr] = SORT_BY[val.to_sym]
    end
  end

  class << self
    def notes_filters
      {
        s_('Notes|Show all activity') => NOTES_FILTERS[:all_notes],
        s_('Notes|Show comments only') => NOTES_FILTERS[:only_comments],
        s_('Notes|Show history only') => NOTES_FILTERS[:only_activity]
      }
    end
  end

  def set_notes_filter(filter_id, issuable)
    # No need to update the column if the value is already set.
    if filter_id && NOTES_FILTERS.values.include?(filter_id)
      field = notes_filter_field_for(issuable)
      self[field] = filter_id

      save if attribute_changed?(field)
    end

    notes_filter_for(issuable)
  end

  # Returns the current discussion filter for a given issuable
  # or issuable type.
  def notes_filter_for(resource)
    self[notes_filter_field_for(resource)]
  end

  private

  def notes_filter_field_for(resource)
    field_key =
      if resource.is_a?(Issuable)
        resource.model_name.param_key
      else
        resource
      end

    "#{field_key}_notes_filter"
  end
end
