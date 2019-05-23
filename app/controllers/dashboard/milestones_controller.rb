# frozen_string_literal: true

class Dashboard::MilestonesController < Dashboard::ApplicationController
  before_action :projects
  before_action :groups, only: :index

  def index
    respond_to do |format|
      format.html do
        @milestone_states = Milestone.states_count(@projects.select(:id), @groups.select(:id))
        @milestones = Kaminari.paginate_array(milestones).page(params[:page])
      end
      format.json do
        render json: milestones
      end
    end
  end

  def show
    render_404
  end

  private

  def milestones
    MilestonesFinder.new(search_params).execute
  end

  def groups
    @groups ||= GroupsFinder.new(current_user, all_available: false).execute
  end

  def search_params
    params.permit(:state, :search_title).merge(group_ids: groups.map(&:id), project_ids: projects.map(&:id))
  end
end
