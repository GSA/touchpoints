class Admin::IvnComponentsController < AdminController
  before_action :set_ivn_component, only: %i[ show edit update destroy ]

  # GET /admin/ivn_components or /admin/ivn_components.json
  def index
    @ivn_components = IvnComponent.all
  end

  # GET /admin/ivn_components/1 or /admin/ivn_components/1.json
  def show
  end

  # GET /admin/ivn_components/new
  def new
    @ivn_component = IvnComponent.new
  end

  # GET /admin/ivn_components/1/edit
  def edit
  end

  # POST /admin/ivn_components or /admin/ivn_components.json
  def create
    @ivn_component = IvnComponent.new(ivn_component_params)

    respond_to do |format|
      if @ivn_component.save
        format.html { redirect_to admin_ivn_component_url(@ivn_component), notice: "Ivn component was successfully created." }
        format.json { render :show, status: :created, location: @ivn_component }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @ivn_component.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/ivn_components/1 or /admin/ivn_components/1.json
  def update
    respond_to do |format|
      if @ivn_component.update(ivn_component_params)
        format.html { redirect_to admin_ivn_component_url(@ivn_component), notice: "Ivn component was successfully updated." }
        format.json { render :show, status: :ok, location: @ivn_component }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @ivn_component.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/ivn_components/1 or /admin/ivn_components/1.json
  def destroy
    @ivn_component.destroy

    respond_to do |format|
      format.html { redirect_to admin_ivn_components_url, notice: "Ivn component was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ivn_component
      @ivn_component = IvnComponent.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def ivn_component_params
      params.require(:ivn_component).permit(:name, :description, :url)
    end
end
