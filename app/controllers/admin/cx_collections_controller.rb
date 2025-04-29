module Admin
  class CxCollectionsController < AdminController
    before_action :set_cx_collection, only: %i[
      show
      edit update submit publish reset no_report
      copy
      destroy
    ]

    def index
      @quarter = params[:quarter]
      @year = params[:year]
      @status = params[:aasm_state]
      scope = performance_manager_permissions? ? CxCollection : current_user.cx_collections
      @all_cx_collections = scope.all
      @filtered_cx_collections = scope.filtered_collections(scope, @quarter, @year, @status)
    end

    def show
      ensure_cx_collection_owner(cx_collection: @cx_collection)

      @events = Event
        .where(object_type: "CxCollection", object_uuid: @cx_collection.id)
        .order("created_at DESC")
    end

    def new
      @cx_collection = CxCollection.new
      @cx_collection.quarter = FiscalYear.fiscal_year_and_quarter(Date.today)[:quarter]
      @cx_collection.fiscal_year = FiscalYear.fiscal_year_and_quarter(Date.today)[:year]
    end

    def edit
      ensure_cx_collection_owner(cx_collection: @cx_collection)
    end

    def export_cx_responses_csv
      ensure_service_manager_permissions

      @quarter = params[:quarter]
      @year = params[:year]
      @status = params[:aasm_state]

      scope = performance_manager_permissions? ? CxCollection : current_user.cx_collections
      cx_collections = CxCollection.filtered_collections(scope, @quarter, @year, @status)

      @cx_collection_detail_ids = []
      # Loop those CxCollections to get their Detail Record ids, and then get those responses
      cx_collections.each do |collection|
        collection.cx_collection_details.each do |collection_detail|
          @cx_collection_detail_ids << collection_detail.id
        end
      end
      @responses = CxResponse.where(cx_collection_detail_id: @cx_collection_detail_ids)
      send_data @responses.to_csv, filename: "touchpoints-data-cx-responses-#{Date.today}.csv"
    end

    def create
      @cx_collection = CxCollection.new(cx_collection_params)
      @cx_collection.organization_id = @cx_collection.service_provider.organization.id

      respond_to do |format|
        if @cx_collection.save
          Event.log_event(Event.names[:cx_collection_created], @cx_collection.class.to_s, @cx_collection.id, "Collection #{@cx_collection.name} created at #{DateTime.now}", current_user.id)
          format.html { redirect_to admin_cx_collection_url(@cx_collection), notice: "CX Data Collection was successfully created." }
          format.json { render :show, status: :created, location: @cx_collection }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @cx_collection.errors, status: :unprocessable_entity }
        end
      end
    end

    def submit
      ensure_cx_collection_owner(cx_collection: @cx_collection)

      @cx_collection.submit!
      Event.log_event(Event.names[:cx_collection_submitted], @cx_collection.class.to_s, @cx_collection.id, "Collection #{@cx_collection.name} submitted at #{DateTime.now}", current_user.id)
      UserMailer.cx_collection_notification(cx_collection_id: @cx_collection.id).deliver_later
      redirect_to admin_cx_collection_path(@cx_collection), notice: 'CX Data Collection has been submitted successfully.'
    end

    def publish
      ensure_performance_manager_permissions

      @cx_collection.publish!
      Event.log_event(Event.names[:cx_collection_published], @cx_collection.class.to_s, @cx_collection.id, "Collection #{@cx_collection.name} published at #{DateTime.now}", current_user.id)
      redirect_to admin_cx_collection_path(@cx_collection), notice: 'CX Data Collection has been published successfully.'
    end

    def no_report
      ensure_performance_manager_permissions

      @cx_collection.submitted_at = nil
      @cx_collection.no_report!
      Event.log_event(Event.names[:cx_collection_not_reported], @cx_collection.class.to_s, @cx_collection.id, "Collection #{@cx_collection.name} reset at #{DateTime.now}", current_user.id)
      redirect_to admin_cx_collection_path(@cx_collection), notice: "CX Data Collection has been marked as 'non-reported' successfully."
    end

    def reset
      ensure_performance_manager_permissions

      @cx_collection.reset!
      Event.log_event(Event.names[:cx_collection_reset], @cx_collection.class.to_s, @cx_collection.id, "Collection #{@cx_collection.name} reset at #{DateTime.now}", current_user.id)
      redirect_to admin_cx_collection_path(@cx_collection), notice: 'CX Data Collection has been reset successfully.'
    end

    def export_csv
      ensure_cx_collection_owner(cx_collection: @cx_collection)

      if performance_manager_permissions?
        @cx_collections = CxCollection.all
      else
        @cx_collections = current_user.cx_collections
      end
      send_data @cx_collections.to_csv, filename: "touchpoints-data-cx-collections-#{Date.today}.csv"
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
      ensure_cx_collection_owner(cx_collection: @cx_collection)

      respond_to do |format|
        if @cx_collection.update(cx_collection_params)
          Event.log_event(Event.names[:cx_collection_updated], @cx_collection.class.to_s, @cx_collection.id, "Collection #{@cx_collection.name} updated at #{DateTime.now}", current_user.id)
          format.html { redirect_to admin_cx_collection_url(@cx_collection), notice: "CX Data Collection was successfully updated." }
          format.json { render :show, status: :ok, location: @cx_collection }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @cx_collection.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      ensure_cx_collection_owner(cx_collection: @cx_collection)

      @cx_collection.destroy

      respond_to do |format|
        Event.log_event(Event.names[:cx_collection_deleted], @cx_collection.class.to_s, @cx_collection.id, "Collection #{@cx_collection.name} deleted at #{DateTime.now}", current_user.id)
        format.html { redirect_to admin_cx_collections_url, notice: "CX Data Collection was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    private
      def set_cx_collection
        if performance_manager_permissions?
          @cx_collection = CxCollection.find(params[:id])
        else
          @cx_collection = current_user.cx_collections.find(params[:id])
        end
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

      def filter_params
        params
          .permit(
            :year,
            :quarter,
            :aasm_state,
          )
      end
  end
end
