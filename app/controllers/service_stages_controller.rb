class ServiceStagesController < ApplicationController
  before_action :ensure_user
  before_action :set_service_stage, only: [:show, :edit, :update, :destroy]

  # GET /service_stages
  def index
    @service_stages = ServiceStage.all
  end

  # GET /service_stages/1
  def show
  end

  # GET /service_stages/new
  def new
    @service_stage = ServiceStage.new
  end

  # GET /service_stages/1/edit
  def edit
  end

  # POST /service_stages
  def create
    @service_stage = ServiceStage.new(service_stage_params)

    if @service_stage.save
      redirect_to @service_stage, notice: 'Service stage was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /service_stages/1
  def update
    if @service_stage.update(service_stage_params)
      redirect_to @service_stage, notice: 'Service stage was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /service_stages/1
  def destroy
    @service_stage.destroy
    redirect_to service_stages_url, notice: 'Service stage was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service_stage
      @service_stage = ServiceStage.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def service_stage_params
      params.require(:service_stage).permit(:name, :description, :service_id, :notes, :time, :total_eligble_population)
    end
end
