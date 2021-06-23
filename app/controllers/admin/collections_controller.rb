class Admin::CollectionsController < AdminController
  before_action :set_collection, only: [:show, :edit, :copy,
    :submit, :publish,
    :update, :destroy
  ]

  def index
    if admin_permissions?
      @collections = Collection.all.order('organizations.name', :year, :quarter).includes(:organization)
    else
      @collections = current_user.organization.collections.order('organizations.name', :year, :quarter).includes(:organization)
    end
  end

  def show
  end

  def new
    @collection = Collection.new
    @collection.year = fiscal_year(Date.today)
    @collection.quarter = fiscal_quarter(Date.today)
  end

  def edit
  end

  def submit
    @collection.submit!
    Event.log_event(Event.names[:collection_submitted], "Collection", @collection.id, "Collection #{@collection.name} submitted at #{DateTime.now}", current_user.id)
    redirect_to admin_collection_path(@collection), notice: 'Collection has been submitted successfully.'
  end

  def publish
    @collection.publish!
    Event.log_event(Event.names[:collection_published], "Collection", @collection.id, "Collection #{@collection.name} published at #{DateTime.now}", current_user.id)
    redirect_to admin_collection_path(@collection), notice: 'Collection has been published successfully.'
  end

  def copy
    respond_to do |format|
      new_collection = @collection.duplicate!(user: current_user)

      if new_collection.valid?
        Event.log_event(Event.names[:collection_copied], "Collection", @collection.id, "Collection #{@collection.name} copied at #{DateTime.now}", current_user.id)

        format.html { redirect_to admin_collection_path(new_collection), notice: 'Collection was successfully copied.' }
        format.json { render :show, status: :created, location: new_collection }
      else
        format.html { render :new }
        format.json { render json: new_collection.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    @collection = Collection.new(collection_params)

    @collection.user = current_user
    if @collection.save
      redirect_to admin_collection_path(@collection), notice: 'Collection was successfully created.'
    else
      render :new
    end
  end

  def update
    if @collection.update(collection_params)
      Event.log_event(Event.names[:collection_updated], "Collection", @collection.id, "Collection #{@collection.name} updated at #{DateTime.now}", current_user.id)
      redirect_to admin_collection_path(@collection), notice: 'Collection was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @collection.destroy
    redirect_to admin_collections_url, notice: 'Collection was successfully destroyed.'
  end

  private
    def set_collection
      if admin_permissions?
        @collection = Collection.find(params[:id])
      else
        @collection = current_user.collections.find(params[:id])
      end
    end

    def collection_params
      params.require(:collection).permit(:name, :start_date, :end_date, :organization_id, :year, :quarter, :user_id,
      :reflection,
      :integrity_hash,
      :aasm_state)
    end
end
