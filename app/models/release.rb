# frozen_string_literal: true

class Release < ActiveRecord::Base
  include CacheMarkdownField

  cache_markdown_field :description

  belongs_to :project
  # releases prior to 11.7 have no author
  belongs_to :author, class_name: 'User'

  validates :description, :project, :tag, presence: true

  scope :sorted, -> { order(created_at: :desc) }

  delegate :repository, to: :project

  def self.by_tag(project, tag)
    self.find_by(project: project, tag: tag)
  end

  def actual_sha
    sha || repository.find_tag(tag)&.dereferenced_target
  end
  
  def commit
    repository.commit(actual_sha)
  end

  def sources_formats
    @sources_formats ||= %w(zip tar.gz tar.bz2 tar).freeze
  end

  # TODO: placeholder for frontend API compatibility
  def links
    []
  end

  def assets_count
    links.size + sources_formats.size
  end
end
