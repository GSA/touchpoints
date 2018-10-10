class TouchpointsController < ApplicationController
  before_action :ensure_user
  before_action :set_touchpoint, only: [:show, :edit, :update, :destroy, :example]

  def index
    @touchpoints = Touchpoint.all
  end

  def show
  end

  def new
    @touchpoint = Touchpoint.new
  end

  def edit
  end

  def create
    @touchpoint = Touchpoint.new(touchpoint_params)

    respond_to do |format|
      if @touchpoint.save
        format.html { redirect_to @touchpoint, notice: 'Touchpoint was successfully created.' }
        format.json { render :show, status: :created, location: @touchpoint }
      else
        format.html { render :new }
        format.json { render json: @touchpoint.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @touchpoint.update(touchpoint_params)
        format.html { redirect_to @touchpoint, notice: 'Touchpoint was successfully updated.' }
        format.json { render :show, status: :ok, location: @touchpoint }
      else
        format.html { render :edit }
        format.json { render json: @touchpoint.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @touchpoint.destroy
    respond_to do |format|
      format.html { redirect_to touchpoints_url, notice: 'Touchpoint was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def example
    render layout: false
  end

  private
    def set_touchpoint
      @touchpoint = Touchpoint.find(params[:id])
    end

    def touchpoint_params
      params.require(:touchpoint).permit(
        :name,
        :organization_id,
        :form_id,
        :purpose,
        :meaningful_response_size,
        :behavior_change,
        :notification_emails,
        :embed_code,
        :enable_google_sheets
      )
    end
end
