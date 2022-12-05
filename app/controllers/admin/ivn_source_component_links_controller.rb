class Admin::IvnSourceComponentLinksController < AdminController
  before_action :set_ivn_source_component_link, only: %i[ show edit update destroy ]

  # GET /admin/ivn_source_component_links or /admin/ivn_source_component_links.json
  def index
    @ivn_source_component_links = IvnSourceComponentLink.all
  end

  # GET /admin/ivn_source_component_links/1 or /admin/ivn_source_component_links/1.json
  def show
  end

  # GET /admin/ivn_source_component_links/new
  def new
    @ivn_source_component_link = IvnSourceComponentLink.new
  end

  # GET /admin/ivn_source_component_links/1/edit
  def edit
  end

  # POST /admin/ivn_source_component_links or /admin/ivn_source_component_links.json
  def create
    @ivn_source_component_link = IvnSourceComponentLink.new(ivn_source_component_link_params)

    respond_to do |format|
      if @ivn_source_component_link.save
        format.html { redirect_to admin_ivn_source_component_link_url(@ivn_source_component_link), notice: "Ivn source component link was successfully created." }
        format.json { render :show, status: :created, location: @ivn_source_component_link }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @ivn_source_component_link.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/ivn_source_component_links/1 or /admin/ivn_source_component_links/1.json
  def update
    respond_to do |format|
      if @ivn_source_component_link.update(ivn_source_component_link_params)
        format.html { redirect_to admin_ivn_source_component_link_url(@ivn_source_component_link), notice: "Ivn source component link was successfully updated." }
        format.json { render :show, status: :ok, location: @ivn_source_component_link }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @ivn_source_component_link.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/ivn_source_component_links/1 or /admin/ivn_source_component_links/1.json
  def destroy
    @ivn_source_component_link.destroy

    respond_to do |format|
      format.html { redirect_to admin_ivn_source_component_links_url, notice: "Ivn source component link was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ivn_source_component_link
      @ivn_source_component_link = IvnSourceComponentLink.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def ivn_source_component_link_params
      params.require(:ivn_source_component_link).permit(:from_id, :to_id)
    end
end
