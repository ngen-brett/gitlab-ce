class Admin::ApplicationsController < Admin::ApplicationController
  include OauthApplications

  before_action :set_application, only: [:show, :edit, :update, :destroy]
  before_action :load_scopes, only: [:new, :create, :edit, :update]

  def index
    @applications = Doorkeeper::Application.where("owner_id IS NULL")
  end

  def show
  end

  def new
    @application = Doorkeeper::Application.new
  end

  def edit
  end

  def create
    @application = Doorkeeper::Application.new(application_params)

    if @application.save
      flash[:notice] = I18n.t(:notice, scope: [:doorkeeper, :flash, :applications, :create])
      redirect_to admin_application_url(@application)
    else
      render :new
    end
  end

  def update
    if @application.update(application_params)
      redirect_to admin_application_path(@application), notice: 'Application was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @application.destroy
    redirect_to admin_applications_url, status: 302, notice: 'Application was successfully destroyed.'
  end

  private

  def set_application
    @application = Doorkeeper::Application.where("owner_id IS NULL").find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def application_params
    params.require(:doorkeeper_application).permit(application_params_ce << application_params_ee)
  end

  def application_params_ce
    %i[
      name
      redirect_uri
      scopes
    ]
  end

  def application_params_ee
    %i[
      trusted
    ]
  end
end
