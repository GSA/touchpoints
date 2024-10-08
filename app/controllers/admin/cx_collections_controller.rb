module Admin
  class CxCollectionsController < AdminController
    before_action :set_cx_collection, only: %i[
      show
      edit update submit publish reset no_report
      copy
      destroy
    ]

    def index
      @quarter = params[:quarter]&.to_i
      @year = params[:year]&.to_i
      @status = params[:aasm_state]

      collection_scope = performance_manager_permissions? ? CxCollection : current_user.cx_collections

      @cx_collections = collection_scope
      @cx_collections = @cx_collections.where(quarter: @quarter) if @quarter && @quarter != 0
      @cx_collections = @cx_collections.where(fiscal_year: @year) if @year && @year != 0
      @cx_collections = @cx_collections.where(aasm_state: @status) if @status && @status != 'All'
      @cx_collections = @cx_collections
        .order('organizations.name', :fiscal_year, :quarter, 'service_providers.name')
        .includes(:organization, :service_provider)
    end

    def show
      @events = Event
        .where(object_type: "CxCollection", object_uuid: @cx_collection.id)
        .order("created_at DESC")
    end

    def new
      @cx_collection = CxCollection.new
    end

    def edit
    end

    def export_cx_responses_csv
      ensure_service_manager_permissions

      @responses = CxResponse.all
      send_data @responses.to_csv, filename: "touchpoints-data-cx-responses-#{Date.today}.csv"
    end

    def create
      @cx_collection = CxCollection.new(cx_collection_params)
      @cx_collection.organization_id = @cx_collection.service_provider.organization.id

      respond_to do |format|
        if @cx_collection.save
          Event.log_event(Event.names[:collection_cx_created], @cx_collection.class.to_s, @cx_collection.id, "Collection #{@cx_collection.name} created at #{DateTime.now}", current_user.id)
          format.html { redirect_to admin_cx_collection_url(@cx_collection), notice: "CX Data Collection was successfully created." }
          format.json { render :show, status: :created, location: @cx_collection }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @cx_collection.errors, status: :unprocessable_entity }
        end
      end
    end

    def submit
      @cx_collection.submit!
      Event.log_event(Event.names[:cx_collection_submitted], @cx_collection.class.to_s, @cx_collection.id, "Collection #{@cx_collection.name} submitted at #{DateTime.now}", current_user.id)
      UserMailer.cx_collection_notification(cx_collection_id: @cx_collection.id).deliver_later
      redirect_to admin_cx_collection_path(@cx_collection), notice: 'CX Data Collection has been submitted successfully.'
    end

    def publish
      @cx_collection.publish!
      Event.log_event(Event.names[:cx_collection_published], @cx_collection.class.to_s, @cx_collection.id, "Collection #{@cx_collection.name} published at #{DateTime.now}", current_user.id)
      redirect_to admin_cx_collection_path(@cx_collection), notice: 'CX Data Collection has been published successfully.'
    end

    def no_report
      @cx_collection.submitted_at = nil
      @cx_collection.no_report!
      Event.log_event(Event.names[:cx_collection_not_reported], @cx_collection.class.to_s, @cx_collection.id, "Collection #{@cx_collection.name} reset at #{DateTime.now}", current_user.id)
      redirect_to admin_cx_collection_path(@cx_collection), notice: "CX Data Collection has been marked as 'non-reported' successfully."
    end

    def reset
      @cx_collection.reset!
      Event.log_event(Event.names[:cx_collection_reset], @cx_collection.class.to_s, @cx_collection.id, "Collection #{@cx_collection.name} reset at #{DateTime.now}", current_user.id)
      redirect_to admin_cx_collection_path(@cx_collection), notice: 'CX Data Collection has been reset successfully.'
    end

    def export_csv
      if performance_manager_permissions?
        @collections = CxCollection.all
      else
        @collections = current_user.cx_collections
      end
      send_data @collections.to_csv, filename: "touchpoints-data-cx-collections-#{Date.today}.csv"
    end

    def copy
      ensure_cx_collection_owner(cx_collection: @cx_collection)

      respond_to do |format|
        new_collection = @cx_collection.duplicate!(new_user: current_user)

        if new_collection.valid?
          Event.log_event(Event.names[:cx_collection_copied], @cx_collection.class.to_s, @cx_collection.id, "Collection #{@cx_collection.name} copied at #{DateTime.now}", current_user.id)

          format.html { redirect_to admin_cx_collection_path(new_collection), notice: 'CX Data Collection was successfully copied.' }
          format.json { render :show, status: :created, location: new_collection }
        else
          format.html { render :new }
          format.json { render json: new_collection.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @cx_collection.update(cx_collection_params)
          Event.log_event(Event.names[:collection_cx_updated], @cx_collection.class.to_s, @cx_collection.id, "Collection #{@cx_collection.name} updated at #{DateTime.now}", current_user.id)
          format.html { redirect_to admin_cx_collection_url(@cx_collection), notice: "CX Data Collection was successfully updated." }
          format.json { render :show, status: :ok, location: @cx_collection }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @cx_collection.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @cx_collection.destroy

      respond_to do |format|
        Event.log_event(Event.names[:cx_collection_deleted], @cx_collection.class.to_s, @cx_collection.id, "Collection #{@cx_collection.name} deleted at #{DateTime.now}", current_user.id)
        format.html { redirect_to admin_cx_collections_url, notice: "CX Data Collection was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    private
      def set_cx_collection
        @cx_collection = CxCollection.find(params[:id])
      end

      def cx_collection_params
        params.require(:cx_collection)
          .permit(:user_id,
            :name,
            :organization_id,
            :service_provider_id,
            :service_id,
            :service_type,
            :url,
            :fiscal_year,
            :quarter,
            :aasm_state,
            :rating
          )
      end
  end
end
