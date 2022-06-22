# frozen_string_literal: true

module Admin
  class ServiceStageBarriersController < AdminController
    before_action :ensure_admin
    before_action :set_service_stage_barrier, only: %i[show edit update destroy]

    def index
      @service_stage_barriers = ServiceStageBarrier.all
    end

    def show; end

    def new
      @service_stage_barrier = ServiceStageBarrier.new
    end

    def edit; end

    def create
      @service_stage_barrier = ServiceStageBarrier.new(service_stage_barrier_params)

      if @service_stage_barrier.save
        redirect_to @service_stage_barrier, notice: 'Service stage barrier was successfully created.'
      else
        render :new
      end
    end

    def update
      if @service_stage_barrier.update(service_stage_barrier_params)
        redirect_to @service_stage_barrier, notice: 'Service stage barrier was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @service_stage_barrier.destroy
      redirect_to service_stage_barriers_url, notice: 'Service stage barrier was successfully destroyed.'
    end

    private

    def set_service_stage_barrier
      @service_stage_barrier = ServiceStageBarrier.find(params[:id])
    end

    def service_stage_barrier_params
      params.require(:service_stage_barrier).permit(:service_stage_id, :barrier_id)
    end
  end
end
