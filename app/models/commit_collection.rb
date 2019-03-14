# frozen_string_literal: true

# A collection of Commit instances for a specific project and Git reference.
class CommitCollection
  include Enumerable
  include Gitlab::Utils::StrongMemoize

  attr_reader :project, :ref, :commits

  # project - The project the commits belong to.
  # commits - The Commit instances to store.
  # ref - The name of the ref (e.g. "master").
  def initialize(project, commits, ref = nil)
    @project = project
    @commits = commits
    @ref = ref
  end

  def each(&block)
    commits.each(&block)
  end

  def authors
    emails = without_merge_commits.map(&:author_email).uniq

    User.by_any_email(emails)
  end

  def without_merge_commits
    strong_memoize(:without_merge_commits) do
      # `#enrich!` the collection to ensure all commits contain
      # the necessary parent data
      enrich!.commits.reject(&:merge_commit?)
    end
  end

  def unenriched
    commits.reject(&:gitaly_commit?)
  end

  def fully_enriched?
    unenriched.empty?
  end

  # Batch load any commits that are not backed by full gitaly data, and
  # replace them in the collection.
  def enrich!
    return self if fully_enriched?

    # Batch load full Commits from the repository
    enriched = unenriched.map { |c| Commit.lazy(project, c.id) }.compact

    # Sanity check, in case commit is not found in gitaly?
    if enriched.count != unenriched.count
      # Do something?
    end

    # Replace the commits, keeping the same order
    replacements = Hash[enriched.map { |c| [c.id, c] }]

    @commits = @commits.map do |c|
      replacements.fetch(c.id, c)
    end

    # reorder?

    self
  end

  # Sets the pipeline status for every commit.
  #
  # Setting this status ahead of time removes the need for running a query for
  # every commit we're displaying.
  def with_pipeline_status
    statuses = project.ci_pipelines.latest_status_per_commit(map(&:id), ref)

    each do |commit|
      commit.set_status_for_ref(ref, statuses[commit.id])
    end

    self
  end

  def respond_to_missing?(message, inc_private = false)
    commits.respond_to?(message, inc_private)
  end

  # rubocop:disable GitlabSecurity/PublicSend
  def method_missing(message, *args, &block)
    commits.public_send(message, *args, &block)
  end
end
