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
  end

  def edit
  end

  def create
    @goal_target = GoalTarget.new(goal_target_params)

    if @goal_target.save
      redirect_to admin_goal_goal_target_path(@goal, @goal_target), notice: 'Goal target was successfully created.'
    else
      render :new
    end
  end

  def update
    if @goal_target.update(goal_target_params)
      redirect_to admin_goal_goal_target_path(@goal, @goal_target), notice: 'Goal target was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @goal_target.destroy
    redirect_to admin_goal_goal_targets_url(@goal), notice: 'Goal target was successfully destroyed.'
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
