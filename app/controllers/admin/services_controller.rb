class Admin::ServicesController < AdminController
  before_action :ensure_admin
  before_action :set_service, only: [
    :show, :edit, :update, :destroy,
    :equity_assessment,
    :omb_cx_reporting,
  ]

  def index
    if !admin_permissions?
      @services = Service.all.includes(:organization).order("organizations.name", :name)
    else
      @services = current_user.organization.services.includes(:organization).order("organizations.name", :name)
    end
  end

  def show
  end

  def new
    @service = Service.new
  end

  def edit
  end

  def create
    @service = Service.new(service_params)
    @service.organization = @service.service_provider.organization

    if @service.save
      redirect_to admin_service_path(@service), notice: 'Service was successfully created.'
    else
      render :new
    end
  end

  def update
    if @service.update(service_params)
      redirect_to admin_service_path(@service), notice: 'Service was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @service.destroy
    redirect_to admin_services_url, notice: 'Service was successfully destroyed.'
  end

  def equity_assessment
  end

  def omb_cx_reporting
  end

  private
    def set_service
      @service = Service.find(params[:id])
    end

    def service_params
      params.require(:service).permit(
        :organization_id,
        :service_provider_id,
        :bureau,
        :bureau_abbreviation,
        :department,
        :description,
        :hisp,
        :name,
        :notes,
        :service_abbreviation,
        :service_slug,
        :url,
      )
    end
end
