class Admin::MilestonesController < AdminController
  before_action :set_milestone, only: [:show, :edit, :update, :destroy]

  def index
    @milestones = Milestone.all
  end

  def show
  end

  def new
    @milestone = Milestone.new
  end

  def edit
  end

  def create
    @milestone = Milestone.new(milestone_params)

    if @milestone.save
      redirect_to admin_milestone_path(@milestone), notice: 'Milestone was successfully created.'
    else
      render :new
    end
  end

  def update
    if @milestone.update(milestone_params)
      redirect_to admin_milestone_path(@milestone), notice: 'Milestone was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
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
