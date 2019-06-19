# frozen_string_literal: true

class RedmineService < IssueTrackerService
  def title
    if self.properties && self.properties['title'].present?
      self.properties['title']
    else
      'Redmine'
    end
  end

  def description
    if self.properties && self.properties['description'].present?
      self.properties['description']
    else
      'Redmine issue tracker'
    end
  end

  def self.to_param
    'redmine'
  end
end
