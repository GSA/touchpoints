class Admin::GoalsController < AdminController
  before_action :set_goal, only: [:show, :edit, :update, :destroy]

  def index
    @goals = Goal.all
  end

  def show
  end

  def new
    @goal = Goal.new
    @goal.organization_id = params[:organization_id]
    @goal.four_year_goal = params[:four_year_goal]
  end

  def edit
  end

  def create
    @goal = Goal.new(goal_params)

    if @goal.save
      redirect_to admin_goal_path(@goal), notice: 'Goal was successfully created.'
    else
      render :new
    end
  end

  def update
    if @goal.update(goal_params)
      redirect_to admin_goal_path(@goal), notice: 'Goal was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @goal.destroy
    redirect_to admin_goals_url, notice: 'Goal was successfully destroyed.'
  end

  private
    def set_goal
      @goal = Goal.find(params[:id])
    end

    def goal_params
      params.require(:goal).permit(
        :organization_id,
        :name,
        :description,
        :tags,
        :users,
        :four_year_goal,
        :parent_id,
      )
    end
end
