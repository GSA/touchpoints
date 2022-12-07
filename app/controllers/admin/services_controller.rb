# frozen_string_literal: true

module Admin
  class ServicesController < AdminController
    before_action :set_service, only: %i[
      show edit
      update
      submit approve verify archive reset
      destroy
      equity_assessment
      omb_cx_reporting
      add_tag
      remove_tag
      add_service_manager
      remove_service_manager
      versions
      export_versions
      add_channel
      remove_channel
    ]
    before_action :set_paper_trail_whodunnit
    before_action :set_service_owner_options, only: %i[
      new
      create
      edit
      update
      add_service_manager
      remove_service_manager
      export_verions
    ]

    before_action :set_service_providers, only: %i[
      new create edit update
    ]

    def index
      tag_name = params[:tag]

      if service_manager_permissions?
        if tag_name.present?
          @services = Service.includes(:organization, :service_provider).order('organizations.name', :name).tagged_with(tag_name)
        else
          @services = Service.all.includes(:organization, :service_provider).order('organizations.name', :name)
        end
      elsif tag_name.present?
        @services = current_user.organization.services.includes(:organization, :service_provider).order('organizations.name', :name).tagged_with(tag_name)
      else
        @services = current_user.organization.services.includes(:organization, :service_provider).order('organizations.name', :name)
      end
      @tags = Service.tag_counts_on(:tags)
    end

    def catalog
      tag_name = params[:tag]

      if service_manager_permissions?
        if tag_name.present?
          @services = Service.includes(:organization).order('organizations.name', :name).tagged_with(tag_name)
        else
          @services = Service.all.includes(:organization).order('organizations.name', :name)
        end
      elsif tag_name.present?
        @services = current_user.organization.services.includes(:organization).order('organizations.name', :name).tagged_with(tag_name)
      else
        @services = current_user.organization.services.includes(:organization).order('organizations.name', :name)
      end
      @tags = Service.tag_counts_on(:tags)
    end

    def versions
      ensure_service_manager_permissions
      @versions = @service.versions.limit(500).order('created_at DESC').page params[:page]
    end

    def export_versions
      ensure_admin
      ExportVersionsJob.perform_later(params[:uuid], @service, 'touchpoints-service-versions.csv')
      render json: { result: :ok }
    end

    def export_csv
      @services = Service.all
      send_data @services.to_csv, filename: "touchpoints-services-#{Date.today}.csv"
    end

    def show; end

    def new
      @service = Service.new
      @service.service_owner_id = current_user.id
      set_channel_options
    end

    def edit
      ensure_service_owner(service: @service, user: current_user)
    end

    def create
      @service = Service.new(service_params)
      @service.service_owner_id = current_user.id
      @service.hisp = @service.service_provider.present?

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
        UserMailer.service_event_notification(subject: 'Service was submitted', service: @service, event: :submitted, link: admin_service_url(@service)).deliver_later
        redirect_to admin_service_path(@service), notice: 'Service was successfully updated.'
      end
    end

    def approve
      ensure_service_owner(service: @service, user: current_user)
      @service.approve
      if @service.save
        UserMailer.service_event_notification(subject: 'Service was approved', service: @service, event: :approved, link: admin_service_url(@service)).deliver_later
        redirect_to admin_service_path(@service), notice: 'Service was successfully updated.'
      end
    end

    def verify
      ensure_service_owner(service: @service, user: current_user)
      @service.verify
      if @service.save
        UserMailer.service_event_notification(subject: 'Service was activated', service: @service, event: :activated, link: admin_service_url(@service)).deliver_later
        redirect_to admin_service_path(@service), notice: 'Service was successfully updated.'
      end
    end

    def archive
      ensure_service_owner(service: @service, user: current_user)
      @service.archive
      if @service.save
        UserMailer.service_event_notification(subject: 'Service was archived', service: @service, event: :archived, link: admin_service_url(@service)).deliver_later
        redirect_to admin_service_path(@service), notice: 'Service was successfully updated.'
      end
    end

    def reset
      ensure_service_owner(service: @service, user: current_user)
      @service.reset
      redirect_to admin_service_path(@service), notice: 'Service was successfully updated.' if @service.save
    end

    def destroy
      ensure_service_owner(service: @service, user: current_user)

      redirect_to admin_services_url, notice: 'Service was successfully destroyed.' if @service.destroy
    end

    def search
      search_text = params[:search]
      tag_name = params[:tag]

      if search_text.present?
        search_text = "%#{search_text}%"
        @services = Service.joins(:organization, :service_provider).where('services.name ilike ? or organizations.name ilike ? OR service_providers.name ilike ?', search_text, search_text, search_text)
      elsif tag_name.present?
        @services = Service.tagged_with(tag_name)
      else
        @services = Service.all
      end
    end

    def add_tag
      @service.tag_list.add(service_params[:tag_list].split(','))
      @service.save
    end

    def remove_tag
      @service.tag_list.remove(service_params[:tag_list].split(','))
      @service.save
    end

    def add_channel
      @service.channel_list.add(params[:channel])
      @service.save
      set_channel_options
    end

    def remove_channel
      @service.channel_list.remove(params[:channel])
      @service.save
      set_channel_options
    end

    def add_service_manager
      @manager = User.find(params[:user_id])
      @manager.add_role :service_manager, @service unless @manager.has_role?(:service_manager, @service)
    end

    def remove_service_manager
      @manager = User.find(params[:user_id])
      @manager.remove_role :service_manager, @service
    end

    def equity_assessment; end

    def omb_cx_reporting; end

    private

    def set_service
      @service = Service.find(params[:id])
      set_channel_options
    end

    def set_service_providers
      if service_manager_permissions?
        @service_providers = ServiceProvider.all.includes(:organization).order('organizations.abbreviation', 'service_providers.name')
      else
        @service_providers = current_user.organization.service_providers.includes(:organization).order('organizations.abbreviation', 'service_providers.name')
      end
    end

    def set_service_owner_options
      if service_manager_permissions?
        @service_owner_options = User.active.order('email')
      else
        @service_owner_options = current_user.organization.users.active.order('email')
      end

      @service_owner_options -= @service.service_managers if @service
    end

    def set_channel_options
      @channel_options = Service.channels
      @channel_options -= @service.channel_list.map(&:to_sym) if @channel_options && @service
    end

    def service_params
      params.require(:service).permit(
        :organization_id,
        :service_owner_id,
        :service_provider_id,
        :bureau_id,
        :office,
        :bureau,
        :department,
        :description,
        :digital_service,
        :estimated_annual_volume_of_customers,
        :hisp,
        :justification_text,

        :name,
        :non_digital_explanation,
        :notes,
        :service_abbreviation,
        :service_slug,
        :url,
        :homepage_url,
        :tag_list,
        :channel_list,
        :where_customers_interact,
        :transactional,
        :channels,
        :fully_digital_service,
        :barriers_to_fully_digital_service,
        :multi_agency_service,
        :multi_agency_explanation,
        :other_service_type,
        :customer_volume_explanation,
        :resources_needed_to_provide_digital_service,
        :designated_for_improvement_a11_280,
        kind: []
      )
    end
  end
end
