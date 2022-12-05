class Admin::IvnLinksController < AdminController
  before_action :set_ivn_link, only: %i[ show edit update destroy ]

  # GET /admin/ivn_links or /admin/ivn_links.json
  def index
    @ivn_links = IvnLink.all
  end

  # GET /admin/ivn_links/1 or /admin/ivn_links/1.json
  def show
  end

  # GET /admin/ivn_links/new
  def new
    @ivn_link = IvnLink.new
  end

  # GET /admin/ivn_links/1/edit
  def edit
  end

  # POST /admin/ivn_links or /admin/ivn_links.json
  def create
    @ivn_link = IvnLink.new(ivn_link_params)

    respond_to do |format|
      if @ivn_link.save
        format.html { redirect_to admin_ivn_link_url(@ivn_link), notice: "Ivn link was successfully created." }
        format.json { render :show, status: :created, location: @ivn_link }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @ivn_link.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/ivn_links/1 or /admin/ivn_links/1.json
  def update
    respond_to do |format|
      if @ivn_link.update(ivn_link_params)
        format.html { redirect_to admin_ivn_link_url(@ivn_link), notice: "Ivn link was successfully updated." }
        format.json { render :show, status: :ok, location: @ivn_link }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @ivn_link.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/ivn_links/1 or /admin/ivn_links/1.json
  def destroy
    @ivn_link.destroy

    respond_to do |format|
      format.html { redirect_to admin_ivn_links_url, notice: "Ivn link was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ivn_link
      @ivn_link = IvnLink.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def ivn_link_params
      params.require(:ivn_link).permit(:from_id, :to_id)
    end
end
