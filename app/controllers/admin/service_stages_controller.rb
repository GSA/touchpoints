# frozen_string_literal: true

module Admin
  class ServiceStagesController < AdminController
    before_action :set_service, except: %i[index export_csv]
    before_action :set_service_stage, only: %i[show edit update destroy]

    def index
      if params[:service_id]
        set_service
        ensure_service_owner(service: @service, user: current_user)
        @service_stages = @service.service_stages.order(:position)
      else
        ensure_service_manager_permissions
        @service_stages = ServiceStage.order(:position)
      end
      respond_to do |format|
        format.html {
          render :index
        }
        format.json {
          render json: @service_stages
        }
      end
    end

    def show
      ensure_service_owner(service: @service, user: current_user)
    end

    def new
      ensure_service_owner(service: @service, user: current_user)
      @service_stage = ServiceStage.new
    end

    def edit
      ensure_service_owner(service: @service, user: current_user)
    end

    def create
      ensure_service_owner(service: @service, user: current_user)
      @service_stage = ServiceStage.new(service_stage_params)
      @service_stage.service = @service

      if @service_stage.save
        redirect_to admin_service_service_stage_path(@service, @service_stage), notice: 'Service stage was successfully created.'
      else
        render :new
      end
    end

    def update
      ensure_service_owner(service: @service, user: current_user)
      if @service_stage.update(service_stage_params)
        redirect_to admin_service_service_stage_path(@service, @service_stage), notice: 'Service stage was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      ensure_service_owner(service: @service, user: current_user)

      redirect_to admin_service_service_stages_url(@service), notice: 'Service stage was successfully destroyed.' if @service_stage.destroy
    end

    def export_csv
      send_data ServiceStage.to_csv, filename: "touchpoints-service-stages-#{Date.today}.csv"
    end

    private

    def set_service
      @service = Service.find(params[:service_id])
    end

    def set_service_stage
      @service_stage = ServiceStage.find(params[:id])
    end

    def service_stage_params
      params.require(:service_stage).permit(:name, :description, :service_id, :notes, :time,
                                            :position,
                                            :persona_id,
                                            :total_eligible_population)
    end
  end
end
