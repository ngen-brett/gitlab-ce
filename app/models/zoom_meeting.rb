# frozen_string_literal: true

class ZoomMeeting < ApplicationRecord
  belongs_to :project
  belongs_to :issue

  validates :project, presence: true
  validates :issue, presence: true
  validates :url, presence: true, public_url: true

  validate :check_issue_association

  private

  def check_issue_association
    return if project == issue.project

    errors.add(:base, 'must be for the same project')
  end
end
