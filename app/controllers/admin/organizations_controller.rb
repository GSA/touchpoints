# frozen_string_literal: true

module Admin
  class OrganizationsController < AdminController
    before_action :set_organization, only: %i[
      show
      performance
      edit
      update
      performance_update
      destroy
      add_tag
      remove_tag
      create_two_year_goal
      create_four_year_goal
      delete_two_year_goal
      delete_four_year_goal
      sort_goals
      sort_objectives
    ]

    def index
      @organizations = Organization.all.order(:name)
      @tags = Organization.tag_counts_by_name
    end

    def show
      @forms = @organization.forms
      @collections = @organization.collections
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
          format.json { render json: @organization.errors, status: :unprocessable_entity }
        end
      end
    end

    def create_four_year_goal
      ensure_performance_manager_permissions

      @goal = Goal.new
      @goal.organization_id = @organization.id
      @goal.four_year_goal = true
      @goal.name = 'New Strategic Goal'
      @goal.save
    end

    def create_two_year_goal
      ensure_performance_manager_permissions

      @goal = Goal.new
      @goal.organization_id = @organization.id
      @goal.four_year_goal = false
      @goal.name = 'New 2 Year APG'
      @goal.save
    end

    def sort_goals
      ensure_performance_manager_permissions

      params[:goal].each_with_index do |id, index|
        Goal.where(id:).update_all(position: index + 1)
      end

      head :ok
    end

    def sort_objectives
      ensure_performance_manager_permissions

      params[:objective].each_with_index do |id, index|
        Objective.where(id:).update_all(position: index + 1)
      end

      head :ok
    end

    def delete_two_year_goal
      ensure_performance_manager_permissions

      Goal.find(params[:goal_id]).destroy
    end

    def delete_four_year_goal
      ensure_performance_manager_permissions

      Goal.find(params[:goal_id]).destroy
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
          format.json { render json: @organization.errors, status: :unprocessable_entity }
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
          format.json { render json: @organization.errors, status: :unprocessable_entity }
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
        @organizations = Organization.where(' domain ilike ? or name ilike ? or abbreviation ilike ? or url ilike ?  ', search_text, search_text, search_text, search_text)
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
      )
    end
  end
end
