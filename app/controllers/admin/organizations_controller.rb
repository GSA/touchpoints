# frozen_string_literal: true

module Admin

  class OrganizationsController < AdminController
    before_action :ensure_admin, except: [
      :performance,
      :performance_update,
    ]

    before_action :set_organization, only: %i[
      show
      performance
      edit
      update
      performance_update
      destroy
      add_tag
      remove_tag
    ]

    def index
      @organizations = Organization.all.order(:name)
      @tags = Organization.tag_counts_by_name
    end

    def show
      @forms = @organization.forms
      @cx_collections = @organization.cx_collections
        .order(:fiscal_year, :quarter)
      @users = @organization.users.active.order(:email)
    end

    def new
      ensure_admin

      @organization = Organization.new
    end

    def edit
      ensure_admin
    end

    def performance
      ensure_performance_manager_permissions
    end

    def create
      ensure_admin

      @organization = Organization.new(organization_params)

      respond_to do |format|
        if @organization.save
          Event.log_event(Event.names[:organization_created], 'Organization', @organization.id, "Organization #{@organization.name} created at #{DateTime.now}", current_user.id)
          format.html { redirect_to admin_organization_path(@organization), notice: 'Organization was successfully created.' }
          format.json { render :show, status: :created, location: @organization }
        else
          format.html { render :new }
          format.json { render json: @organization.errors, status: :unprocessable_content }
        end
      end
    end

    def update
      ensure_admin

      respond_to do |format|
        if @organization.update(organization_params)
          Event.log_event(Event.names[:organization_updated], 'Organization', @organization.id, "Organization #{@organization.name} updated at #{DateTime.now}", current_user.id)
          format.html { redirect_to admin_organization_path(@organization), notice: 'Organization was successfully updated.' }
          format.json { render :show, status: :ok, location: @organization }
        else
          format.html { render :edit }
          format.json { render json: @organization.errors, status: :unprocessable_content }
        end
      end
    end

    def performance_update
      ensure_performance_manager_permissions

      respond_to do |format|
        if @organization.update(organization_params)
          format.html { redirect_to performance_admin_organization_path(@organization), notice: 'Organization was successfully updated.' }
          format.json { render :show, status: :ok, location: @organization }
        else
          format.html { render :edit }
          format.json { render json: @organization.errors, status: :unprocessable_content }
        end
      end
    end

    def destroy
      ensure_admin

      @organization.destroy
      Event.log_event(Event.names[:organization_deleted], 'Organization', @organization.id, "Organization #{@organization.name} deleted at #{DateTime.now}", current_user.id)

      respond_to do |format|
        format.html { redirect_to admin_organizations_url, notice: 'Organization was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    def search
      search_text = params[:search]
      tag_name = params[:tag]
      if search_text.present?
        search_text = "%#{search_text}%"
        @organizations = Organization.where('domain ILIKE ? or name ILIKE ? or abbreviation ILIKE ? or url ILIKE ?', search_text, search_text, search_text, search_text)
      elsif tag_name.present?
        @organizations = Organization.tagged_with(tag_name)
      else
        @organizations = Organization.all
      end
    end

    def add_tag
      ensure_admin

      @organization.tag_list.add(organization_params[:tag_list].split(','))
      @organization.save
    end

    def remove_tag
      ensure_admin

      @organization.tag_list.remove(organization_params[:tag_list].split(','))
      @organization.save
    end

    private

    def set_organization
      @organization = Organization.find_by_id(params[:id]) || Organization.find_by_abbreviation(params[:id].upcase)
    end

    def organization_params
      params.require(:organization).permit(
        :parent_id,
        :name,
        :domain,
        :logo,
        :url,
        :abbreviation,
        :notes,
        :external_id,
        :enable_ip_address,
        :digital_analytics_path,
        :mission_statement,
        :mission_statement_url,
        :tag_list,
        :performance_url,
        :strategic_plan_url,
        :learning_agenda_url,
        :cfo_act_agency,
        :form_approval_enabled,
      )
    end
  end
end
