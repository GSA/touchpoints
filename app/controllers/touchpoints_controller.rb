class TouchpointsController < ApplicationController
  before_action :set_touchpoint, only: [:show, :edit, :update, :destroy]

  # GET /touchpoints
  # GET /touchpoints.json
  def index
    @touchpoints = Touchpoint.all
  end

  # GET /touchpoints/1
  # GET /touchpoints/1.json
  def show
  end

  # GET /touchpoints/new
  def new
    @touchpoint = Touchpoint.new
  end

  # GET /touchpoints/1/edit
  def edit
  end

  # POST /touchpoints
  # POST /touchpoints.json
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

  # PATCH/PUT /touchpoints/1
  # PATCH/PUT /touchpoints/1.json
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

  # DELETE /touchpoints/1
  # DELETE /touchpoints/1.json
  def destroy
    @touchpoint.destroy
    respond_to do |format|
      format.html { redirect_to touchpoints_url, notice: 'Touchpoint was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_touchpoint
      @touchpoint = Touchpoint.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def touchpoint_params
      params.require(:touchpoint).permit(:name, :organization_id, :purpose, :meaningful_response_size, :behavior_change, :notification_emails, :embed_code)
    end
end
