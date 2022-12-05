class Admin::IvnSourcesController < AdminController
  before_action :set_ivn_source, only: %i[ show edit update destroy ]

  # GET /admin/ivn_sources or /admin/ivn_sources.json
  def index
    @ivn_sources = IvnSource.all
  end

  # GET /admin/ivn_sources/1 or /admin/ivn_sources/1.json
  def show
  end

  # GET /admin/ivn_sources/new
  def new
    @ivn_source = IvnSource.new
  end

  # GET /admin/ivn_sources/1/edit
  def edit
  end

  # POST /admin/ivn_sources or /admin/ivn_sources.json
  def create
    @ivn_source = IvnSource.new(ivn_source_params)

    respond_to do |format|
      if @ivn_source.save
        format.html { redirect_to admin_ivn_source_url(@ivn_source), notice: "Ivn source was successfully created." }
        format.json { render :show, status: :created, location: @ivn_source }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @ivn_source.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/ivn_sources/1 or /admin/ivn_sources/1.json
  def update
    respond_to do |format|
      if @ivn_source.update(ivn_source_params)
        format.html { redirect_to admin_ivn_source_url(@ivn_source), notice: "Ivn source was successfully updated." }
        format.json { render :show, status: :ok, location: @ivn_source }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @ivn_source.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/ivn_sources/1 or /admin/ivn_sources/1.json
  def destroy
    @ivn_source.destroy

    respond_to do |format|
      format.html { redirect_to admin_ivn_sources_url, notice: "Ivn source was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ivn_source
      @ivn_source = IvnSource.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def ivn_source_params
      params.require(:ivn_source).permit(
        :name,
        :description,
        :url,
        :organization_id
      )
    end
end
