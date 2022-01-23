class Admin::ObjectivesController < AdminController
  before_action :set_goal
  before_action :set_objective, only: [:show, :edit, :update, :destroy]

  # GET /objectives
  def index
    @objectives = @goal.objectives
  end

  # GET /objectives/1
  def show
  end

  # GET /objectives/new
  def new
    @objective = Objective.new
    @objective.goal_id = @goal.id
    render :layout => false
  end

  # GET /objectives/1/edit
  def edit
    render :layout => false
  end

  # POST /objectives
  def create
    @objective = Objective.new(objective_params)
    @objective.goal_id = @goal.id
    @objective.save!
  end

  # PATCH/PUT /objectives/1
  def update
    @objective.update(objective_params)
    @objective.tags = objective_params[:tags].split(" ")
    @objective.users = [objective_params[:users].to_i] if objective_params[:users].present?
    @objective.save!
  end

  # DELETE /objectives/1
  def destroy
    @objective.destroy
  end

  private
    def set_goal
      @goal = Goal.find(params[:goal_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_objective
      @objective = Objective.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def objective_params
      params.require(:objective).permit(:name, :description, :organization_id, :goal_id, :milestone_id, :tags, :users)
    end
end
