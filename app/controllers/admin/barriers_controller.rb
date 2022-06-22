# frozen_string_literal: true

module Admin
  class BarriersController < AdminController
    before_action :ensure_admin
    before_action :set_barrier, only: %i[show edit update destroy]

    def index
      @barriers = Barrier.all
    end

    def show; end

    def new
      @barrier = Barrier.new
    end

    def edit; end

    def create
      @barrier = Barrier.new(barrier_params)

      if @barrier.save
        redirect_to admin_barrier_path(@barrier), notice: 'Barrier was successfully created.'
      else
        render :new
      end
    end

    def update
      if @barrier.update(barrier_params)
        redirect_to admin_barrier_path(@barrier), notice: 'Barrier was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @barrier.destroy
      redirect_to admin_barriers_url, notice: 'Barrier was successfully destroyed.'
    end

    private

    def set_barrier
      @barrier = Barrier.find(params[:id])
    end

    def barrier_params
      params.require(:barrier).permit(:name, :description)
    end
  end
end
