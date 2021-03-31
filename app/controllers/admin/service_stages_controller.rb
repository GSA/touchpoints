class Admin::ServiceStagesController < AdminController
  before_action :ensure_admin
  before_action :set_service
  before_action :set_service_stage, only: [:show, :edit, :update, :destroy]

  def index
    @service_stages = @service.service_stages
  end

  def show
  end

  def new
    @service_stage = ServiceStage.new
  end

  def edit
  end

  def create
    @service_stage = ServiceStage.new(service_stage_params)

    if @service_stage.save
      redirect_to admin_service_service_stage_path(@service, @service_stage), notice: 'Service stage was successfully created.'
    else
      render :new
    end
  end

  def update
    if @service_stage.update(service_stage_params)
      redirect_to admin_service_service_stage_path(@service, @service_stage), notice: 'Service stage was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @service_stage.destroy
    redirect_to admin_service_service_stages_url(@service), notice: 'Service stage was successfully destroyed.'
  end

  private

    def set_service
      @service = Service.find(params[:service_id])
    end

    def set_service_stage
      @service_stage = ServiceStage.find(params[:id])
    end

    def service_stage_params
      params.require(:service_stage).permit(:name, :description, :service_id, :notes, :time, :total_eligble_population)
    end
end
