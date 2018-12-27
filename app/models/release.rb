# frozen_string_literal: true

class Release < ActiveRecord::Base
  include CacheMarkdownField
  include Gitlab::Utils::StrongMemoize

  cache_markdown_field :description

  belongs_to :project
  # releases prior to 11.7 have no author
  belongs_to :author, class_name: 'User'

  validates :description, :project, :tag, presence: true
  validates :tag, uniqueness: { scope: :project }
  validates :sha, presence: true, on: :create
  validates :name, presence: true

  scope :sorted, -> { order(created_at: :desc) }

  delegate :repository, to: :project

  def self.by_tag(project, tag)
    self.find_by(project: project, tag: tag)
  end

  def commit
    strong_memoize(:commit) do
      repository.commit(actual_sha)
    end
  end

  def tag_missing?
    actual_tag.nil?
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

  private

  def actual_sha
    sha || actual_tag&.dereferenced_target
  end

  def actual_tag
    strong_memoize(:actual_tag) do
      repository.find_tag(tag)
    end
  end
end
