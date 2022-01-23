class Admin::GoalTargetsController < AdminController
  before_action :set_goal
  before_action :set_goal_target, only: [:show, :edit, :update, :destroy]

  def index
    @goal_targets = GoalTarget.all
  end

  def show

  end

  def new
    @goal_target = GoalTarget.new
    render :layout => false
  end

  def edit
    render :layout => false
  end

  def create
    @goal_target = GoalTarget.new(goal_target_params)
    @goal_target.save
  end

  def update
    @goal_target.update(goal_target_params)
  end

  def destroy
    @goal_target.destroy
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
