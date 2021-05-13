class Admin::CollectionsController < AdminController
  before_action :ensure_admin
  before_action :set_collection, only: [:show, :edit, :update, :destroy]

  # GET /collections
  def index
    @collections = Collection.all
  end

  # GET /collections/1
  def show
  end

  # GET /collections/new
  def new
    @collection = Collection.new
  end

  # GET /collections/1/edit
  def edit
  end

  # POST /collections
  def create
    @collection = Collection.new(collection_params)

    @collection.user = current_user
    if @collection.save
      redirect_to admin_collection_path(@collection), notice: 'Collection was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /collections/1
  def update
    if @collection.update(collection_params)
      redirect_to admin_collection_path(@collection), notice: 'Collection was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /collections/1
  def destroy
    @collection.destroy
    redirect_to admin_collections_url, notice: 'Collection was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection
      @collection = Collection.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def collection_params
      params.require(:collection).permit(:name, :start_date, :end_date, :organization_id, :year, :quarter, :user_id, :integrity_hash,
      :aasm_state)
    end
end
