module Admin
  class CxCollectionsController < AdminController
    before_action :set_cx_collection, only: %i[
      show
      edit update submit publish
      copy
      destroy
    ]

    def index
      @cx_collections = CxCollection.all.includes(:organization, :service_provider)
    end

    def show
    end

    def new
      @cx_collection = CxCollection.new
    end

    def edit
    end

    def create
      @cx_collection = CxCollection.new(cx_collection_params)

      respond_to do |format|
        if @cx_collection.save
          format.html { redirect_to admin_cx_collection_url(@cx_collection), notice: "Cx collection was successfully created." }
          format.json { render :show, status: :created, location: @cx_collection }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @cx_collection.errors, status: :unprocessable_entity }
        end
      end
    end

    def submit
      @cx_collection.submit!
      Event.log_event(Event.names[:collection_submitted], 'Collection', @cx_collection.id, "Collection #{@cx_collection.name} submitted at #{DateTime.now}", current_user.id)
      UserMailer.collection_notification(collection_id: @cx_collection.id).deliver_later
      redirect_to admin_cx_collection_path(@cx_collection), notice: 'Collection has been submitted successfully.'
    end

    def publish
      @cx_collection.publish!
      Event.log_event(Event.names[:collection_published], 'Collection', @cx_collection.id, "Collection #{@cx_collection.name} published at #{DateTime.now}", current_user.id)
      redirect_to admin_cx_collection_path(@cx_collection), notice: 'Collection has been published successfully.'
    end

    def copy
      ensure_collection_owner(collection: @cx_collection)

      respond_to do |format|
        new_collection = @cx_collection.duplicate!(new_user: current_user)

        if new_collection.valid?
          Event.log_event(Event.names[:collection_copied], 'Collection', @cx_collection.id, "Collection #{@cx_collection.name} copied at #{DateTime.now}", current_user.id)

          format.html { redirect_to admin_collection_path(new_collection), notice: 'Collection was successfully copied.' }
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
          format.html { redirect_to admin_cx_collection_url(@cx_collection), notice: "Cx collection was successfully updated." }
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
        format.html { redirect_to admin_cx_collections_url, notice: "CX collection was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    private
      def set_cx_collection
        @cx_collection = CxCollection.find(params[:id])
      end

      def cx_collection_params
        params.require(:cx_collection).permit(:user_id, :name, :organization_id, :service_provider_id, :service_id, :service_type, :digital_service_or_contact_center, :url, :fiscal_year, :quarter, :start_date, :end_date, :transaction_point, :service_stage_id, :channel, :survey_title, :trust_question_text, :likert_or_thumb_question, :number_of_interactions, :number_of_people_offered_the_survey, :reflection, :aasm_state, :rating, :integrity_hash)
      end
  end
end
