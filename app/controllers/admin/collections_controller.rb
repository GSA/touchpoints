# frozen_string_literal: true

module Admin
  class CollectionsController < AdminController
    before_action :set_collection, only: %i[show edit copy
                                            submit publish
                                            update destroy
                                            events]

    def index
      @quarter = params[:quarter].present? ? params[:quarter].to_i : nil
      @year = params[:year].present? ? params[:year].to_i : nil

      @collections = if performance_manager_permissions?
                       if @quarter && @year
                         Collection.where(quarter: @quarter, year: @year)
                                   .order('organizations.name', :year, :quarter, 'service_providers.name')
                                   .includes(:organization, :service_provider)
                       elsif @quarter
                         Collection.where(quarter: @quarter)
                                   .order('organizations.name', :year, :quarter, 'service_providers.name')
                                   .includes(:organization, :service_provider)
                       else
                         Collection.all
                                   .order('organizations.name', :year, :quarter, 'service_providers.name')
                                   .includes(:organization, :service_provider)
                       end
                     elsif @quarter && @year
                       current_user.collections.where(quarter: @quarter, year: @year)
                                   .order('organizations.name', :year, :quarter, 'service_providers.name')
                                   .includes(:organization, :service_provider)
                     elsif @quarter
                       current_user.collections.where(quarter: @quarter)
                                   .order('organizations.name', :year, :quarter, 'service_providers.name')
                                   .includes(:organization, :service_provider)
                     else
                       current_user.collections
                                   .order('organizations.name', :year, :quarter, 'service_providers.name')
                                   .includes(:organization, :service_provider)
                     end
    end

    def show
      ensure_collection_owner(collection: @collection)
    end

    def new
      @collection = Collection.new
      @collection.user = current_user
      @collection.organization_id = params[:organization_id]
      @collection.service_provider_id = params[:service_provider_id]
      @collection.year = fiscal_year(Date.today)
      @collection.quarter = fiscal_quarter(Date.today)
    end

    def edit
      ensure_collection_owner(collection: @collection)
    end

    def submit
      @collection.submit!
      Event.log_event(Event.names[:collection_submitted], 'Collection', @collection.id,
                      "Collection #{@collection.name} submitted at #{DateTime.now}", current_user.id)
      UserMailer.collection_notification(collection_id: @collection.id).deliver_later
      redirect_to admin_collection_path(@collection), notice: 'Collection has been submitted successfully.'
    end

    def publish
      @collection.publish!
      Event.log_event(Event.names[:collection_published], 'Collection', @collection.id,
                      "Collection #{@collection.name} published at #{DateTime.now}", current_user.id)
      redirect_to admin_collection_path(@collection), notice: 'Collection has been published successfully.'
    end

    def copy
      ensure_collection_owner(collection: @collection)

      respond_to do |format|
        new_collection = @collection.duplicate!(new_user: current_user)

        if new_collection.valid?
          Event.log_event(Event.names[:collection_copied], 'Collection', @collection.id,
                          "Collection #{@collection.name} copied at #{DateTime.now}", current_user.id)

          format.html do
            redirect_to admin_collection_path(new_collection), notice: 'Collection was successfully copied.'
          end
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
        Event.log_event(Event.names[:collection_created], 'Collection', @collection.id,
                        "Collection #{@collection.name} created at #{DateTime.now}", current_user.id)
        redirect_to admin_collection_path(@collection), notice: 'Collection was successfully created.'
      else
        render :new
      end
    end

    def update
      ensure_collection_owner(collection: @collection)

      if @collection.update(collection_params)
        Event.log_event(Event.names[:collection_updated], 'Collection', @collection.id,
                        "Collection #{@collection.name} updated at #{DateTime.now}", current_user.id)
        redirect_to admin_collection_path(@collection), notice: 'Collection was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      ensure_collection_owner(collection: @collection)
      @collection.destroy
      Event.log_event(Event.names[:collection_deleted], 'Collection', @collection.id,
                      "Collection #{@collection.name} deleted at #{DateTime.now}", current_user.id)
      redirect_to admin_collections_url, notice: 'Collection was successfully destroyed.'
    end

    def events
      @events = Event.where(object_type: 'Collection', object_id: @collection.id).order(:created_at)
    end

    private

    def set_collection
      @collection = if performance_manager_permissions?
                      Collection.find(params[:id])
                    else
                      current_user.collections.find(params[:id])
                    end
    end

    def collection_params
      params.require(:collection).permit(
        :name,
        :start_date,
        :end_date,
        :organization_id,
        :service_provider_id,
        :year,
        :quarter,
        :user_id,
        :reflection,
        :integrity_hash,
        :aasm_state,
        :rating
      )
    end
  end
end
