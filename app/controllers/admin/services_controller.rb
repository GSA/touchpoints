class Admin::ServicesController < AdminController
  before_action :set_service, only: [
    :show, :edit,
    :update,
    :submit, :approve, :activate, :archive, :reset,
    :destroy,
    :equity_assessment,
    :omb_cx_reporting,
    :add_tag,
    :remove_tag,
  ]

  before_action :set_service_owner_options, only: [
    :new,
    :create,
    :edit,
    :update
  ]

  before_action :set_service_providers, only: [
    :new, :create, :edit
  ]

  def index
    tag_name = params[:tag]

    if admin_permissions?
      if tag_name.present?
        @services = Service.tagged_with(tag_name).includes(:organization).order("organizations.name", :name)
      else
        @services = Service.all.includes(:organization).order("organizations.name", :name)
      end
    else
      if tag_name.present?
        @services = current_user.organization.services.tagged_with(tag_name).includes(:organization).order("organizations.name", :name)
      else
        @services = current_user.organization.services.includes(:organization).order("organizations.name", :name)
      end
    end
    @tags = Service.tag_counts_on(:tags)
  end

  def show
  end

  def new
    @service = Service.new
    @service.service_owner_id = current_user.id
  end

  def edit
    ensure_service_owner(service: @service, user: current_user)
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
    ensure_service_owner(service: @service, user: current_user)

    if @service.update(service_params)
      redirect_to admin_service_path(@service), notice: 'Service was successfully updated.'
    else
      render :edit
    end
  end

  def submit
    ensure_service_owner(service: @service, user: current_user)
    @service.submit
    if @service.save
      UserMailer.event_notification(subject: "Data Collection submitted", body: @service.id, link: admin_service_url(@service)).deliver_later
      redirect_to admin_service_path(@service), notice: 'Service was successfully updated.'
    end
  end

  def approve
    ensure_service_owner(service: @service, user: current_user)
    @service.approve
    if @service.save
      redirect_to admin_service_path(@service), notice: 'Service was successfully updated.'
    end
  end

  def activate
    ensure_service_owner(service: @service, user: current_user)
    @service.activate
    if @service.save
      UserMailer.event_notification(subject: "Data Collection activated", body: @service.id, link: admin_service_url(@service)).deliver_later
      redirect_to admin_service_path(@service), notice: 'Service was successfully updated.'
    end
  end

  def archive
    ensure_service_owner(service: @service, user: current_user)
    @service.archive
    if @service.save
      UserMailer.event_notification(subject: "Data Collection archived", body: @service.id, link: admin_service_url(@service)).deliver_later
      redirect_to admin_service_path(@service), notice: 'Service was successfully updated.'
    end
  end

  def reset
    ensure_service_owner(service: @service, user: current_user)
    @service.reset
    if @service.save
      redirect_to admin_service_path(@service), notice: 'Service was successfully updated.'
    end
  end

  def destroy
    ensure_service_owner(service: @service, user: current_user)

    if @service.destroy
      redirect_to admin_services_url, notice: 'Service was successfully destroyed.'
    end
  end

  def search
    search_text = params[:search]
    tag_name = params[:tag]
    if search_text.present?
      search_text = "%" + search_text + "%"
      @services = Service.joins(:organization).where(" services.name ilike ? or organizations.name ilike ?  ", search_text, search_text)
    elsif tag_name.present?
      @services = Service.tagged_with(tag_name)
    else
      @services = Service.all
    end
  end

  def add_tag
    @service.tag_list.add(service_params[:tag_list].split(","))
    @service.save
  end

  def remove_tag
    @service.tag_list.remove(service_params[:tag_list].split(","))
    @service.save
  end

  def equity_assessment
  end

  def omb_cx_reporting
  end

  private
    def set_service
      @service = Service.find(params[:id])
    end

    def set_service_providers
      if admin_permissions?
        @service_providers = ServiceProvider.all.includes(:organization).order("organizations.abbreviation", "service_providers.name")
      else
        @service_providers = current_user.organization.service_providers.includes(:organization).order("organizations.abbreviation", "service_providers.name")
      end
    end


    def set_service_owner_options
      if admin_permissions?
        @service_owner_options = User.active
      else
        @service_owner_options = current_user.organization.users
      end
    end



    def service_params
      params.require(:service).permit(
        :organization_id,
        :service_owner_id,
        :service_provider_id,
        :bureau,
        :bureau_abbreviation,
        :department,
        :description,
        :hisp,
        :justification_text,
        :name,
        :notes,
        :service_abbreviation,
        :service_slug,
        :url,
        :tag_list,
        :where_customers_interact,
      )
    end
end
