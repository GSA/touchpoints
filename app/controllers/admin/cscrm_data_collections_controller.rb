# frozen_string_literal: true

module Admin
  class CscrmDataCollectionsController < AdminController
    before_action :set_cscrm_data_collection, only: %i[
      show
      edit update
      submit publish reset
      destroy
    ]

    def index
      respond_to do |format|
        format.html do
          if cscrm_manager_permissions?
            @cscrm_data_collections = CscrmDataCollection.includes(:organization)
          else
            # Redirect non-admin users to CSCRM2
            redirect_to admin_cscrm_data_collections2_index_path
          end
        end
        format.csv do
          if cscrm_manager_permissions?
            csv_content = CscrmDataCollection.to_csv
          else
            []
          end
          send_data csv_content
        end
      end
    end

    def show; end

    def new
      @cscrm_data_collection = CscrmDataCollection.new
    end

    def edit; end

    def create
      @cscrm_data_collection = CscrmDataCollection.new(cscrm_data_collection_params)
      @cscrm_data_collection.user = current_user unless @cscrm_data_collection.user

      respond_to do |format|
        if @cscrm_data_collection.save
          Event.log_event(Event.names[:cscrm_data_collection_collection_created], 'CSRCM Data Collection', @cscrm_data_collection.id, "CSRCM Data Collection #{@cscrm_data_collection.id} created at #{DateTime.now}", current_user.id)
          format.html { redirect_to admin_cscrm_data_collection_url(@cscrm_data_collection), notice: 'Cscrm data collection was successfully created.' }
          format.json { render :show, status: :created, location: @cscrm_data_collection }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @cscrm_data_collection.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      @cscrm_data_collection.user = current_user unless @cscrm_data_collection.user

      respond_to do |format|
        if @cscrm_data_collection.update(cscrm_data_collection_params)
          Event.log_event(Event.names[:cscrm_data_collection_collection_updated], 'CSRCM Data Collection', @cscrm_data_collection.id, "CSRCM Data Collection #{@cscrm_data_collection.id} updated at #{DateTime.now}", current_user.id)
          format.html { redirect_to admin_cscrm_data_collection_url(@cscrm_data_collection), notice: 'Cscrm data collection was successfully updated.' }
          format.json { render :show, status: :ok, location: @cscrm_data_collection }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @cscrm_data_collection.errors, status: :unprocessable_entity }
        end
      end
    end

    def submit
      @cscrm_data_collection.submit!
      Event.log_event(Event.names[:cscrm_data_collection_collection_submitted], 'CSRCM Data Collection', @cscrm_data_collection.id, "CSRCM Data Collection #{@cscrm_data_collection.id} submitted at #{DateTime.now}", current_user.id)
      UserMailer.cscrm_data_collection_notification(collection_id: @cscrm_data_collection.id).deliver_later
      redirect_to admin_cscrm_data_collection_path(@cscrm_data_collection), notice: 'CSRCM Data Collection has been submitted successfully.'
    end

    def publish
      @cscrm_data_collection.publish!
      Event.log_event(Event.names[:cscrm_data_collection_collection_published], 'CSRCM Data Collection', @cscrm_data_collection.id, "CSRCM Data Collection #{@cscrm_data_collection.id} published at #{DateTime.now}", current_user.id)
      redirect_to admin_cscrm_data_collection_path(@cscrm_data_collection), notice: 'CSRCM Data Collection has been published successfully.'
    end

    def reset
      if cscrm_manager_permissions?
        @cscrm_data_collection.reset!
        Event.log_event(Event.names[:cscrm_data_collection_collection_reset], 'CSRCM Data Collection', @cscrm_data_collection.id, "CSRCM Data Collection #{@cscrm_data_collection.id} reset at #{DateTime.now}", current_user.id)
        redirect_to admin_cscrm_data_collection_path(@cscrm_data_collection), notice: 'CSRCM Data Collection has been reset.'
      end
    end

    def destroy
      @cscrm_data_collection.destroy
      Event.log_event(Event.names[:cscrm_data_collection_collection_deleted], 'CSRCM Data Collection', @cscrm_data_collection.id, "CSRCM Data Collection #{@cscrm_data_collection.id} deleted at #{DateTime.now}", current_user.id)

      respond_to do |format|
        format.html { redirect_to admin_cscrm_data_collections_url, notice: 'Cscrm data collection was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private

    def set_cscrm_data_collection
      if cscrm_manager_permissions?
        @cscrm_data_collection = CscrmDataCollection.find(params[:id])
      else
        @cscrm_data_collection = current_user.organization.cscrm_data_collections.find(params[:id])
      end
    end

    def cscrm_data_collection_params
      params.require(:cscrm_data_collection).permit(
        :user_id,
        :organization_id,
        :bureau,
        :year,
        :quarter,
        :agency_roles,
        :agency_roles_comments,
        :leadership_roles,
        :leadership_roles_comments,
        :stakeholder_champion_identified,
        :stakeholder_champion_identified_comments,
        :pmo_established,
        :pmo_established_comments,
        :interdisciplinary_team_established,
        :interdisciplinary_team_established_comments,
        :enterprise_risk_management_function_established,
        :enterprise_risk_management_function_established_comments,
        :enterprise_wide_scrm_policy_established,
        :enterprise_wide_scrm_policy_established_comments,
        :agency_wide_scrm_strategy_and_implementation_plan_established,
        :agency_wide_scrm_strategy_and_implementation_plan_comments,
        :funding_for_initial_operating_capability,
        :funding_for_initial_operating_capability_comments,
        :staffing,
        :staffing_comments,
        :personnel_required_comments,
        :cybersecurity_supply_chain_risk_comments,
        :prioritization_process,
        :prioritization_process_comments,
        :established_process_information_sharing_with_fasc,
        :established_process_information_sharing_with_fasc_comments,
        :general_comments,
        :rating,
        :roles_and_responsibilities_comments,
        :missions_identified_comments,
        :considerations_in_procurement_processes_comments,
        :conducts_scra_for_prioritized_products_and_services_comments,
        roles_and_responsibilities: [],
        missions_identified: [],
        considerations_in_procurement_processes: [],
        conducts_scra_for_prioritized_products_and_services: [],
        personnel_required_to_complete_training: [],
        cybersecurity_supply_chain_risk_considerations: [],
      )
    end
  end
end
