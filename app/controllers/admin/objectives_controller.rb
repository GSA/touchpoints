class Admin::ObjectivesController < AdminController
  before_action :set_objective, only: [:show, :edit, :update, :destroy]

  # GET /objectives
  def index
    @objectives = Objective.all
  end

  # GET /objectives/1
  def show
  end

  # GET /objectives/new
  def new
    @objective = Objective.new
  end

  # GET /objectives/1/edit
  def edit
  end

  # POST /objectives
  def create
    @objective = Objective.new(objective_params)
    @objective.organization_id = current_user.organization_id

    if @objective.save
      redirect_to admin_objective_path(@objective), notice: 'Objective was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /objectives/1
  def update
    if @objective.update(objective_params)
      redirect_to admin_objective_path(@objective), notice: 'Objective was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /objectives/1
  def destroy
    @objective.destroy
    redirect_to admin_objectives_url, notice: 'Objective was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_objective
      @objective = Objective.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def objective_params
      params.require(:objective).permit(:name, :description, :organization_id, :goal_id, :milestone_id, :tags, :users)
    end
end
