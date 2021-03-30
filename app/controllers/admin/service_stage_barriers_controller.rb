class Admin::ServiceStageBarriersController < AdminController
  before_action :ensure_admin
  before_action :set_service_stage_barrier, only: [:show, :edit, :update, :destroy]

  # GET /service_stage_barriers
  def index
    @service_stage_barriers = ServiceStageBarrier.all
  end

  # GET /service_stage_barriers/1
  def show
  end

  # GET /service_stage_barriers/new
  def new
    @service_stage_barrier = ServiceStageBarrier.new
  end

  # GET /service_stage_barriers/1/edit
  def edit
  end

  # POST /service_stage_barriers
  def create
    @service_stage_barrier = ServiceStageBarrier.new(service_stage_barrier_params)

    if @service_stage_barrier.save
      redirect_to @service_stage_barrier, notice: 'Service stage barrier was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /service_stage_barriers/1
  def update
    if @service_stage_barrier.update(service_stage_barrier_params)
      redirect_to @service_stage_barrier, notice: 'Service stage barrier was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /service_stage_barriers/1
  def destroy
    @service_stage_barrier.destroy
    redirect_to service_stage_barriers_url, notice: 'Service stage barrier was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service_stage_barrier
      @service_stage_barrier = ServiceStageBarrier.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def service_stage_barrier_params
      params.require(:service_stage_barrier).permit(:service_stage_id, :barrier_id)
    end
end
