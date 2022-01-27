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
    @objective.organization_id = @goal.organization_id
    @objective.name = 'New Objective'
    render :layout => false
  end

  # GET /objectives/1/edit
  def edit
    render :layout => false
  end

  # POST /objectives
  def create
    @objective = Objective.new(objective_params)
    respond_to do |format|
      if @objective.save!
        format.html { redirect_to admin_objective_path(@objective), notice: 'Objective was successfully created.'}
        format.json { render :create, status: :created, goal: @goal }
        format.js
      else
        format.html { render :new }
        format.json { render json: @objective.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # PATCH/PUT /objectives/1
  def update
    @objective.update(objective_params)
    @objective.tags = objective_params[:tags].split(" ")
    @objective.users = [objective_params[:users].to_i] if objective_params[:users].present?
    respond_to do |format|
      if @objective.save
        format.html { redirect_to admin_objective_path(@objective), notice: 'Objective was successfully updated.'}
        format.json { render :update, status: :updated, goal: @goal }
        format.js
      else
        format.html { render :edit }
        format.json { render json: @objective.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /objectives/1
  def destroy
    @objective.destroy
    respond_to do |format|
      format.html { redirect_to admin_objectives_url, notice: 'Objective was successfully destroyed.'}
      format.json { render :destroy, status: :deleted, goal: @goal }
      format.js
    end
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
