# frozen_string_literal: true

module Admin
  class ObjectivesController < AdminController
    before_action :set_goal
    before_action :set_objective, only: %i[show edit update destroy add_tag remove_tag]
    before_action :set_objective_tags, only: %i[edit add_tag remove_tag]

    def index
      @objectives = @goal.objectives
    end

    def show; end

    def new
      ensure_performance_manager_permissions

      @objective = Objective.new
      @objective.goal_id = @goal.id
      @objective.organization_id = @goal.organization_id
      @objective.name = 'New Objective'
      render layout: false
    end

    def edit
      ensure_performance_manager_permissions

      render layout: false
    end

    def create
      ensure_performance_manager_permissions

      @objective = Objective.new(objective_params)
      respond_to do |format|
        if @objective.save!
          format.html { redirect_to admin_objective_path(@objective), notice: 'Objective was successfully created.' }
          format.json { render :create, status: :created, goal: @goal }
        else
          format.html { render :new }
          format.json { render json: @objective.errors, status: :unprocessable_entity }
        end
        format.js
      end
    end

    def update
      ensure_performance_manager_permissions

      @objective.update(objective_params)
      @objective.users = [objective_params[:users].to_i] if objective_params[:users].present?
      respond_to do |format|
        if @objective.save
          format.html { redirect_to admin_objective_path(@objective), notice: 'Objective was successfully updated.' }
          format.json { render :update, status: :updated, goal: @goal }
        else
          format.html { render :edit }
          format.json { render json: @objective.errors, status: :unprocessable_entity }
        end
        format.js
      end
    end

    def destroy
      ensure_performance_manager_permissions

      @objective.destroy
      respond_to do |format|
        format.html { redirect_to admin_objectives_url, notice: 'Objective was successfully destroyed.' }
        format.json { render :destroy, status: :deleted, goal: @goal }
        format.js
      end
    end

    def add_tag
      @objective.tag_list.add(objective_params[:tag_list].split(','))
      @objective.save
    end

    def remove_tag
      @objective.tag_list.remove(objective_params[:tag_list].split(','))
      @objective.save
    end

    private

    def set_goal
      @goal = Goal.find(params[:goal_id])
    end

    def set_objective
      @objective = Objective.find(params[:id])
    end

    def set_objective_tags
      @objective_tags_for_select = Goal::TAGS
    end

    def objective_params
      params.require(:objective).permit(
        :name,
        :description,
        :organization_id,
        :goal_id,
        :milestone_id,
        :tags,
        :users,
        :tag_list,
      )
    end
  end
end
