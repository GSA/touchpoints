class BarriersController < ApplicationController
  before_action :ensure_user
  before_action :set_barrier, only: [:show, :edit, :update, :destroy]

  # GET /barriers
  def index
    @barriers = Barrier.all
  end

  # GET /barriers/1
  def show
  end

  # GET /barriers/new
  def new
    @barrier = Barrier.new
  end

  # GET /barriers/1/edit
  def edit
  end

  # POST /barriers
  def create
    @barrier = Barrier.new(barrier_params)

    if @barrier.save
      redirect_to @barrier, notice: 'Barrier was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /barriers/1
  def update
    if @barrier.update(barrier_params)
      redirect_to @barrier, notice: 'Barrier was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /barriers/1
  def destroy
    @barrier.destroy
    redirect_to barriers_url, notice: 'Barrier was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_barrier
      @barrier = Barrier.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def barrier_params
      params.require(:barrier).permit(:name, :description)
    end
end
