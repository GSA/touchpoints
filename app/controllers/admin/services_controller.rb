class Admin::ServicesController < ApplicationController
  before_action :ensure_user
  before_action :set_service, only: [:show, :edit, :update, :destroy, :equity_assessment]

  # GET /services
  def index
    @services = Service.all
  end

  # GET /services/1
  def show
  end

  # GET /services/new
  def new
    @service = Service.new
  end

  # GET /services/1/edit
  def edit
  end

  # POST /services
  def create
    @service = Service.new(service_params)

    if @service.save
      redirect_to admin_service_path(@service), notice: 'Service was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /services/1
  def update
    if @service.update(service_params)
      redirect_to @service, notice: 'Service was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /services/1
  def destroy
    @service.destroy
    redirect_to services_url, notice: 'Service was successfully destroyed.'
  end

  def equity_assessment
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service
      @service = Service.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def service_params
      params.require(:service).permit(:name, :description, :organization_id, :notes)
    end
end
