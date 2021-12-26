class Admin::ServiceProvidersController < AdminController
  before_action :set_service_provider, only: [:show, :edit, :update, :destroy, :add_tag, :remove_tag]
  before_action :ensure_admin, except: [:show]

  def index
    @service_providers = ServiceProvider.all.includes(:organization).order("organizations.name", "service_providers.name")
    @tags = tag_counts('ServiceProvider','tags')
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

  def search
    search_text = params[:search]
    tag_name = params[:tag]
    if search_text.present?
      search_text = "%" + search_text + "%"
      @service_providers = ServiceProvider.joins(:organization).where(" service_providers.name ilike ? or organizations.name ilike ?  ", search_text, search_text)
    elsif tag_name.present?
      @service_providers = ServiceProvider.tagged_with(tag_name)
    else
      @service_providers = ServiceProvider.all
    end
  end

  def add_tag
    @service_provider.tag_list.add(service_provider_params[:tag_list].split(","))
    @service_provider.save
  end

  def remove_tag
    @service_provider.tag_list.remove(service_provider_params[:tag_list].split(","))
    @service_provider.save
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
        :inactive,
        :new,
        :tag_list,
      )
    end
end
