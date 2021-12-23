class Admin::GoalTargetsController < AdminController
  before_action :set_goal
  before_action :set_goal_target, only: [:show, :edit, :update, :destroy]

  # GET /goal_targets
  def index
    @goal_targets = GoalTarget.all
  end

  # GET /goal_targets/1
  def show
  end

  # GET /goal_targets/new
  def new
    @goal_target = GoalTarget.new
  end

  # GET /goal_targets/1/edit
  def edit
  end

  # POST /goal_targets
  def create
    @goal_target = GoalTarget.new(goal_target_params)

    if @goal_target.save
      redirect_to @goal_target, notice: 'Goal target was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /goal_targets/1
  def update
    if @goal_target.update(goal_target_params)
      redirect_to @goal_target, notice: 'Goal target was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /goal_targets/1
  def destroy
    @goal_target.destroy
    redirect_to goal_targets_url, notice: 'Goal target was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_goal
      @goal = Goal.find(params[:goal_id])
    end

    def set_goal_target
      @goal_target = GoalTarget.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def goal_target_params
      params.require(:goal_target).permit(:goal_id, :target_date_at, :assertion, :kpi, :starting_value, :target_value, :current_value)
    end
end
