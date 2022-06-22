# frozen_string_literal: true

module Admin
  class GoalTargetsController < AdminController
    before_action :set_goal
    before_action :set_goal_target, only: %i[show edit update destroy]

    def index
      @goal_targets = GoalTarget.all
    end

    def show; end

    def new
      @goal_target = GoalTarget.new
      @goal_target.assertion = 'New goal target'
      @goal_target.starting_value = 0
      @goal_target.target_value = 0
      @goal_target.current_value = 0
      render layout: false
    end

    def edit
      render layout: false
    end

    def create
      ensure_performance_manager_permissions

      @goal_target = GoalTarget.new(goal_target_params)

      respond_to do |format|
        if @goal_target.save
          format.html { redirect_to admin_goal_goal_target_path(@goal, @goal_target), notice: 'Goal target was successfully created.' }
          format.json { render :create, status: :created, goal: @goal }
        else
          format.html { render :new }
          format.json { render json: @goal_target.errors, status: :unprocessable_entity }
        end
        format.js
      end
    end

    def update
      ensure_performance_manager_permissions

      respond_to do |format|
        if @goal_target.update(goal_target_params)
          format.html { redirect_to admin_goal_goal_target_path(@goal, @goal_target), notice: 'Goal target was successfully updated.' }
          format.json { render :update, status: :updated, goal: @goal }
        else
          format.html { render :edit }
          format.json { render json: @goal_target.errors, status: :unprocessable_entity }
        end
        format.js
      end
    end

    def destroy
      ensure_performance_manager_permissions
      @goal_target.destroy

      respond_to do |format|
        format.html { redirect_to admin_goal_goal_targets_url(@goal), notice: 'Goal target was successfully destroyed.' }
        format.json { render :destroy, status: :deleted, goal: @goal }
        format.js
      end
    end

    private

    def set_goal
      @goal = Goal.find(params[:goal_id])
    end

    def set_goal_target
      @goal_target = GoalTarget.find(params[:id])
    end

    def goal_target_params
      params.require(:goal_target).permit(:goal_id, :target_date_at, :assertion, :kpi, :starting_value, :target_value, :current_value)
    end
  end
end
