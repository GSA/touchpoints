# frozen_string_literal: true

module Admin
  class MilestonesController < AdminController
    before_action :set_milestone, only: %i[show edit update destroy]

    def index
      @milestones = Milestone.all
    end

    def show; end

    def new
      ensure_performance_manager_permissions

      @milestone = Milestone.new
    end

    def edit
      ensure_performance_manager_permissions
    end

    def create
      ensure_performance_manager_permissions

      @milestone = Milestone.new(milestone_params)

      if @milestone.save
        redirect_to admin_milestone_path(@milestone), notice: 'Milestone was successfully created.'
      else
        render :new
      end
    end

    def update
      ensure_performance_manager_permissions

      if @milestone.update(milestone_params)
        redirect_to admin_milestone_path(@milestone), notice: 'Milestone was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      ensure_performance_manager_permissions

      @milestone.destroy
      redirect_to admin_milestones_url, notice: 'Milestone was successfully destroyed.'
    end

    private

    def set_milestone
      @milestone = Milestone.find(params[:id])
    end

    def milestone_params
      params.require(:milestone).permit(
        :organization_id,
        :goal_id,
        :name,
        :description,
        :due_date,
        :status,
        :notes,
      )
    end
  end
end
