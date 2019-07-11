# frozen_string_literal: true

# Controller for viewing a file's raw
class Projects::RawController < Projects::ApplicationController
  include ExtractsPath
  include SendsBlob

  before_action :require_non_empty_project
  before_action :assign_ref_vars
  before_action :authorize_download_code!
  before_action :show_rate_limit, only: [:show]

  def show
    @blob = @repository.blob_at(@commit.id, @path)

    send_blob(@repository, @blob, inline: (params[:inline] != 'false'))
  end

  private

  def show_rate_limit
    limiter = ::Gitlab::ActionRateLimiter.new(action: :show_raw_controller)

    # If there's a user we need to include it
    return unless limiter.throttled?([@repository, @commit, @path], 1)

    flash[:alert] = _('You cannot access to the raw file. Please wait a minute')
    redirect_to fast_project_blob_path(@project, tree_join(commit.id, @path))
  end
end
