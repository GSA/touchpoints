class Admin::ServiceProvidersController < AdminController
  before_action :set_service_provider, only: [:show, :edit, :update, :destroy]

  def index
    @service_providers = ServiceProvider.all.includes(:organization).order("organizations.name", "service_providers.name")
  end

  def show
  end

  def new
    @service_provider = ServiceProvider.new
  end

  def edit
  end

  def create
    @service_provider = ServiceProvider.new(service_provider_params)

    if @service_provider.save
      redirect_to admin_service_provider_path(@service_provider), notice: 'Service provider was successfully created.'
    else
      render :new
    end
  end

  def update
    if @service_provider.update(service_provider_params)
      redirect_to admin_service_provider_path(@service_provider), notice: 'Service provider was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @service_provider.destroy
    redirect_to admin_service_providers_url, notice: 'Service provider was successfully destroyed.'
  end

  private
    def set_service_provider
      @service_provider = ServiceProvider.find(params[:id])
    end

    def service_provider_params
      params.require(:service_provider).permit(
        :organization_id,
        :name,
        :description,
        :notes,
        :slug,
        :department,
        :department_abbreviation,
        :bureau,
        :bureau_abbreviation,
      )
    end
end
