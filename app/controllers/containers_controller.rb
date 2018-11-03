class ContainersController < ApplicationController
  before_action :ensure_admin
  before_action :set_container, only: [:show, :edit, :update, :destroy]

  def index
    if current_user && current_user.admin?
      @containers = Container.all
    else
      @containers = current_user.organization.containers
    end
  end

  def show
  end

  def new
    @container = Container.new
  end

  def edit
  end

  def create
    @container = Container.new(container_params)

    respond_to do |format|
      if @container.save
        format.html { redirect_to @container, notice: 'Container was successfully created.' }
        format.json { render :show, status: :created, location: @container }
      else
        format.html { render :new }
        format.json { render json: @container.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @container.update(container_params)
        format.html { redirect_to @container, notice: 'Container was successfully updated.' }
        format.json { render :show, status: :ok, location: @container }
      else
        format.html { render :edit }
        format.json { render json: @container.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @container.destroy
    respond_to do |format|
      format.html { redirect_to containers_url, notice: 'Container was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_container
      @container = Container.find(params[:id])
    end

    def container_params
      params.require(:container).permit(
        :name,
        :gtm_container_id,
        :gtm_container_public_id,
        :organization_id
      )
    end
end
