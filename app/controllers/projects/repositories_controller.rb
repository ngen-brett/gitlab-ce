# frozen_string_literal: true

class Projects::RepositoriesController < Projects::ApplicationController
  include ExtractsPath

  # Authorize
  before_action :require_non_empty_project, except: :create
  before_action :assign_archive_vars, only: :archive
  before_action :authorize_download_code!
  before_action :authorize_admin_project!, only: :create

  def create
    @project.create_repository

    redirect_to project_path(@project)
  end

  def archive
    append_sha = params[:append_sha]

    if @ref
      shortname = "#{@project.path}-#{@ref.tr('/', '-')}"
      append_sha = false if @filename == shortname
    end

    kwargs = {ref: @ref, path: params[:path], format: params[:format], append_sha: append_sha}

    return if cached_archive?(@repository, **kwargs)

    send_git_archive @repository, **kwargs
  rescue => ex
    logger.error("#{self.class.name}: #{ex}")
    git_not_found!
  end

  private

  def cached_archive?(repository, ref:, format:, append_sha:, path:)
    storage_path = '' # Where archives are stored isn't really important for ETag purposes
    metadata = repository.archive_metadata(ref, storage_path, format, append_sha: append_sha, path: path)
    stale = stale?(etag: metadata['ArchivePath']) # The #stale? method sets cache headers.

    # Because we are opinionated we set the cache headers ourselves.
    response.cache_control[:public] = project.public?

    response.cache_control[:max_age] =
      if ref == metadata['CommitId']
        # FIXME
        Blob::CACHE_TIME_IMMUTABLE
      else
        # FIXME
        Blob::CACHE_TIME
      end

    response.etag = metadata['ArchivePath']
    !stale
  end

  def assign_archive_vars
    if params[:id]
      @ref, @filename = extract_ref(params[:id])
    else
      @ref = params[:ref]
      @filename = nil
    end
  rescue InvalidPathError
    render_404
  end
end
