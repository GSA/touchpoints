# frozen_string_literal: true

module Admin
  class WebsitesController < AdminController
    before_action :set_paper_trail_whodunnit

    before_action :ensure_organizational_website_manager, only: %i[
      approve
      deny
      reset
      collection_preview
      collection_request
      export_versions
    ]

    before_action :set_website, only: %i[
      show costs statuscard edit update destroy collection_request
      approve
      deny
      develop
      stage
      launch
      redirect
      archive
      decommission
      reset
      events
      dendrogram
      add_tag
      remove_tag
      versions
      export_versions
      add_website_manager
      remove_website_manager
      add_website_persona
      remove_website_persona
    ]

    before_action lambda {
      ensure_website_admin(website: @website)
    }, only: %i[
      edit
      update
      develop
      stage
      launch
      redirect
      archive
      decommission
    ]

    before_action :set_website_manager_options, only: %i[
      new
      create
      edit
      update
      add_website_manager
      remove_website_manager
    ]

    before_action :set_website_persona_options, only: %i[
      new
      create
      edit
      update
    ]

    def index
      if params[:all]
        @websites = Website.all.includes(:taggings).order(:production_status, :domain)
      else
        @websites = Website.active.includes(:taggings).order(:production_status, :domain)
      end
      @tags = Website.includes(:taggings).tag_counts_by_name
    end

    def review
      @websites = Website.where(production_status: 'newly_requested').includes(:taggings).order(:production_status, :domain)
      @tags = Website.tag_counts_by_name
    end

    def versions
      @versions = @website.versions.limit(500).order('created_at DESC').page params[:page]
    end

    def export_versions
      ensure_admin
      ExportVersionsJob.perform_later(params[:uuid], @website, 'touchpoints-website-versions.csv')
      render json: { result: :ok }
    end

    def dendrogram; end

    def dendrogram_json
      if params['office'] == 'true'
        dendrogram_json_by_office
      else
        # default
        dendrogram_json_by_domain
      end

      respond_to do |format|
        format.json do
          render 'dendrogram_json'
        end
      end
    end

    def dendrogram_json_by_domain
      @websites = []

      # loop all sites and build a list of top-level domains
      @active_websites = Website.active
      @active_websites.each do |website|
        next unless website.tld?

        @websites << {
          name: website.domain,
          children: [],
        }
      end

      @active_websites.each do |website|
        selected_website = @websites.select { |w| w[:name] == website[:domain] || w[:name] == website[:parent_domain] }.first
        next if selected_website.blank?

        next if website.tld?

        selected_website[:children] << {
          name: website.domain || 'N/A',
          value: 1,
        }
      end
      @websites
    end

    def dendrogram_json_by_office
      @websites = []

      # loop all sites and build a list of top-level domains
      @active_websites = Website.active
      @active_websites.collect(&:office).uniq.each do |office|
        @websites << {
          name: office,
          office:,
          children: [],
        }
      end

      @active_websites.each do |website|
        selected_website = @websites.select { |w| w[:office] == website[:office] || w[:sub_office] == website[:sub_office] }.first
        next if selected_website.blank?

        selected_website[:children] << {
          name: website.domain || 'N/A',
          value: 1,
        }
      end
      @websites
    end

    def export_csv
      @websites = Website.all
      send_data @websites.to_csv, filename: "touchpoints-websites-#{Date.today}.csv"
    end

    def statuscard; end

    def search
      search_text = params[:search]
      tag_name = params[:tag]
      if search_text.present?
        search_text = "%#{search_text}%"
        managed_sites = Website.where(id: Website.ids_by_manager_search(search_text))
        @websites = Website.where(' domain ilike ? or office ilike ? or sub_office ilike ? or production_status ilike ? or site_owner_email ilike ? ', search_text, search_text, search_text, search_text, search_text).or(managed_sites).order(
          :production_status, :domain
        )
      elsif tag_name.present?
        @websites = Website.tagged_with(tag_name).order(:production_status, :domain)
      else
        @websites = Website.all.order(:production_status, :domain)
      end
    end

    def gsa
      @websites = Website.active.order(:production_status, :domain)
    end

    def show
      @events = Event.where(object_type: 'Website', object_id: @website.id.to_s)
        .includes(:user)
        .order('created_at DESC')
    end

    def collection_preview
      ensure_admin
      @websites = Website.active.order(:site_owner_email, :domain)
    end

    def collection_request
      # fetch all websites for site owner
      @websites = Website.active.where(site_owner_email: @website.site_owner_email)
      # only include websites which are missing data
      @websites = @websites.select(&:requiresDataCollection?)
      UserMailer.website_data_collection(@website.site_owner_email, @websites).deliver_later if @website.site_owner_email.present?
      UserMailer.website_data_collection(current_user.email, @websites).deliver_later
      redirect_to admin_websites_url, notice: "Website data collection request was successfully sent for #{@website.domain}"
    end

    def new
      @website = Website.new
      @website.site_owner_email = current_user.email
      @website.contact_email = current_user.email
    end

    def edit; end

    def costs; end

    def create
      @website = Website.new(admin_website_params)

      if @website.save
        Event.log_event(Event.names[:website_created], 'Website', @website.id, "Website #{@website.domain} created at #{DateTime.now}", current_user.id)
        UserMailer.website_created(website: @website).deliver_later
        redirect_to admin_website_url(@website), notice: 'Website was successfully created.'
      else
        render :new
      end
    end

    def update
      current_state = @website.production_status
      if @website.update(admin_website_params)
        log_update(current_state)
        redirect_to admin_website_url(@website), notice: 'Website was successfully updated.'
      else
        render :edit
      end
    end

    def approve
      if @website.approve!
        Event.log_event(Event.names[:website_approved], 'Website', @website.id, "Website #{@website.domain} approved at #{DateTime.now}", current_user.id)
        redirect_to admin_website_url(@website), notice: "Website #{@website.domain} was approved."
      else
        render :edit
      end
    end

    def deny
      if @website.deny!
        Event.log_event(Event.names[:website_denied], 'Website', @website.id, "Website #{@website.domain} denied at #{DateTime.now}", current_user.id)
        redirect_to admin_website_url(@website), notice: "Website #{@website.domain} was denied."
      else
        render :edit
      end
    end

    def develop
      if @website.start_development!
        Event.log_event(Event.names[:website_start_development], 'Website', @website.id, "Website #{@website.domain} begins development at #{DateTime.now}", current_user.id)
        redirect_to admin_website_url(@website), notice: "Website #{@website.domain} in now in development."
      else
        render :edit
      end
    end

    def stage
      if @website.stage!
        Event.log_event(Event.names[:website_staged], 'Website', @website.id, "Website #{@website.domain} was updated to Staging at #{DateTime.now}", current_user.id)
        redirect_to admin_website_url(@website), notice: "Website #{@website.domain} has been staged."
      else
        render :edit
      end
    end

    def launch
      if @website.launch!
        Event.log_event(Event.names[:website_launched], 'Website', @website.id, "Website #{@website.domain} was launched at #{DateTime.now}", current_user.id)
        redirect_to admin_website_url(@website), notice: "Website #{@website.domain} has been launched."
      else
        render :edit
      end
    end

    def redirect
      if @website.redirect!
        Event.log_event(Event.names[:website_redirected], 'Website', @website.id, "Website #{@website.domain} was redirected at #{DateTime.now}", current_user.id)
        redirect_to admin_website_url(@website), notice: "Website #{@website.domain} has been redirected."
      else
        render :edit
      end
    end

    def archive
      if @website.archive!
        Event.log_event(Event.names[:website_archived], 'Website', @website.id, "Website #{@website.domain} was archived at #{DateTime.now}", current_user.id)
        redirect_to admin_website_url(@website), notice: "Website #{@website.domain} has been archived."
      else
        render :edit
      end
    end

    def decommission
      if @website.decommission!
        Event.log_event(Event.names[:website_decommissioned], 'Website', @website.id, "Website #{@website.domain} was decommissioned at #{DateTime.now}", current_user.id)
        redirect_to admin_website_url(@website), notice: "Website #{@website.domain} has been decommissioned."
      else
        render :edit
      end
    end

    def reset
      if @website.reset!
        Event.log_event(Event.names[:website_reset], 'Website', @website.id, "Website #{@website.domain} was reset at #{DateTime.now}", current_user.id)
        redirect_to admin_website_url(@website), notice: "Website #{@website.domain} has been reset to newly_requested status."
      else
        render :edit
      end
    end

    def destroy
      ensure_admin

      @website.destroy
      Event.log_event(Event.names[:website_deleted], 'Website', @website.id, "Website #{@website.domain} deleted at #{DateTime.now}", current_user.id)
      redirect_to admin_websites_url, notice: 'Website was successfully destroyed.'
    end

    def events
      @events = Event.where(object_type: 'Website', object_id: @website.id).order(:created_at)
    end

    def add_tag
      @website.tag_list.add(admin_website_params[:tag_list].split(','))
      @website.save
    end

    def remove_tag
      @website.tag_list.remove(admin_website_params[:tag_list].split(','))
      @website.save
    end

    def add_website_manager
      @manager = User.find(params[:user_id])
      @manager.add_role :website_manager, @website unless @manager.has_role?(:website_manager, @website)
    end

    def remove_website_manager
      @manager = User.find(params[:user_id])
      @manager.remove_role :website_manager, @website
    end

    def add_website_persona
      @website.persona_list.add(params[:persona_id])
      @website.save
      set_website_persona_options
    end

    def remove_website_persona
      @website.persona_list.remove(params[:persona_id])
      @website.save
      set_website_persona_options
    end

    private

    def set_website_manager_options
      if admin_permissions?
        @website_manager_options = User.active.order('email')
      elsif @website&.organization
        @website_manager_options = @website.organization.users.active.order('email')
      elsif current_user.organization
        @website_manager_options = current_user.organization.users.active.order('email')
      else
        []
      end

      @website_manager_options -= @website.website_managers if @website_manager_options && @website
    end

    def set_website_persona_options
      @website_persona_options = Persona.all.order(:name)
      @website_persona_options -= @website.website_personas if @website_persona_options && @website
    end

    def log_update(current_state)
      Event.log_event(Event.names[:website_updated], 'Website', @website.id, "Website #{@website.domain} updated at #{DateTime.now}", current_user.id)
      Event.log_event(Event.names[:website_state_changed], 'Website', @website.id, "Website #{@website.domain} state changed to #{admin_website_params[:production_status]} at #{DateTime.now}", current_user.id) if admin_website_params[:production_status] != current_state
    end

    def set_website
      @website = Website.find_by_id(params[:id])
    end

    def admin_website_params
      params.require(:website).permit(:domain, :office, :office_id, :sub_office, :suboffice_id, :contact_email, :site_owner_email, :production_status, :type_of_site, :digital_brand_category, :redirects_to, :status_code, :cms_platform, :required_by_law_or_policy, :has_dap, :dap_gtm_code, :cost_estimator_url, :modernization_plan_url, :annual_baseline_cost,
                                      :modernization_cost,
                                      :modernization_cost_2021,
                                      :modernization_cost_2022,
                                      :modernization_cost_2023,
                                      :analytics_url,
                                      :https,
                                      :uswds_version,
                                      :uses_feedback, :feedback_tool, :sitemap_url, :mobile_friendly, :has_search, :uses_tracking_cookies,
                                      :hosting_platform,
                                      :has_authenticated_experience,
                                      :authentication_tool,
                                      :repository_url,
                                      :notes,
                                      :tag_list,
                                      :service_id,
                                      :organization_id)
    end
  end
end
