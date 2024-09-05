# frozen_string_literal: true

module Admin
  class CscrmDataCollections2Controller < AdminController
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
            @cscrm_data_collections = CscrmDataCollection2.includes(:organization)
          else
            @cscrm_data_collections = current_user.organization.cscrm_data_collections2.includes(:organization)
          end
        end
        format.csv do
          if cscrm_manager_permissions?
            csv_content = CscrmDataCollection2.to_csv
          else
            []
          end
          send_data csv_content
        end
      end
    end

    def show; end

    def new
      @cscrm_data_collection = CscrmDataCollection2.new
    end

    def edit; end

    def create
      @cscrm_data_collection = CscrmDataCollection2.new(cscrm_data_collection_params)
      @cscrm_data_collection.user = current_user unless @cscrm_data_collection.user

      respond_to do |format|
        if @cscrm_data_collection.save
          Event.log_event(Event.names[:cscrm_data_collection_collection_created], 'CSRCM Data Collection', @cscrm_data_collection.id, "CSRCM Data Collection #{@cscrm_data_collection.id} created at #{DateTime.now}", current_user.id)
          format.html { redirect_to admin_cscrm_data_collections2_url(@cscrm_data_collection), notice: 'Cscrm data collection was successfully created.' }
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
          format.html { redirect_to admin_cscrm_data_collections2_url(@cscrm_data_collection), notice: 'Cscrm data collection was successfully updated.' }
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
      UserMailer.cscrm_data_collection2_notification(collection_id: @cscrm_data_collection.id).deliver_later
      redirect_to admin_cscrm_data_collections2_path(@cscrm_data_collection), notice: 'CSRCM Data Collection has been submitted successfully.'
    end

    def publish
      @cscrm_data_collection.publish!
      Event.log_event(Event.names[:cscrm_data_collection_collection_published], 'CSRCM Data Collection', @cscrm_data_collection.id, "CSRCM Data Collection #{@cscrm_data_collection.id} published at #{DateTime.now}", current_user.id)
      redirect_to admin_cscrm_data_collections2_path(@cscrm_data_collection), notice: 'CSRCM Data Collection has been published successfully.'
    end

    def reset
      if cscrm_manager_permissions?
        @cscrm_data_collection.reset!
        Event.log_event(Event.names[:cscrm_data_collection_collection_reset], 'CSRCM Data Collection', @cscrm_data_collection.id, "CSRCM Data Collection #{@cscrm_data_collection.id} reset at #{DateTime.now}", current_user.id)
        redirect_to admin_cscrm_data_collections2_path(@cscrm_data_collection), notice: 'CSRCM Data Collection has been reset.'
      end
    end

    def destroy
      @cscrm_data_collection.destroy
      Event.log_event(Event.names[:cscrm_data_collection_collection_deleted], 'CSRCM Data Collection', @cscrm_data_collection.id, "CSRCM Data Collection #{@cscrm_data_collection.id} deleted at #{DateTime.now}", current_user.id)

      respond_to do |format|
        format.html { redirect_to admin_cscrm_data_collections2_index_url, notice: 'Cscrm data collection was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private

    def set_cscrm_data_collection
      if cscrm_manager_permissions?
        @cscrm_data_collection = CscrmDataCollection2.find(params[:id])
      else
        @cscrm_data_collection = current_user.organization.cscrm_data_collections2.find(params[:id])
      end
    end

    def cscrm_data_collection_params
      params.require(:cscrm_data_collection2).permit(
        :user_id,
        :organization_id,
        :bureau_id,
        :year,
        :quarter,
        :rating,
        # Question 1
        :interdisciplinary_team,
        :interdisciplinary_team_comments,
        :pmo_established,
        :pmo_established_comments,
        :established_policy,
        :established_policy_comments,
        :supply_chain_acquisition_procedures,
        :supply_chain_acquisition_procedures_comments,
        # Question 5
        :funding,
        :funding_comments,
        :identified_staff,
        :identified_staff_comments,
        :strategy_plan,
        :strategy_plan_comments,
        :governance_structure,
        :governance_structure_comments,
        # clearly_defined_roles,
        :clearly_defined_roles_comments,
        # Question 10
        # :identified_assets_and_essential_functions,
        :identified_assets_and_essential_functions_comments,
        :prioritization_process,
        :prioritization_process_comments,
        # :considerations_in_procurement_processes,
        :considerations_in_procurement_processes_comments,
        :documented_methodology,
        :documented_methodology_comments,
        # :conducts_scra_for_prioritized_products_and_services,
        :conducts_scra_for_prioritized_products_and_services_comments,
        # Question 15
        :personnel_required_to_complete_training,
        :personnel_required_to_complete_training_comments,
        :established_process_information_sharing_with_fasc,
        :established_process_information_sharing_with_fasc_comments,
        # :cybersecurity_supply_chain_risk_considerations,
        :cybersecurity_supply_chain_risk_considerations_comments,
        :process_for_product_authenticity,
        :process_for_product_authenticity_comments,
        :cscrm_controls_incorporated_into_ssp,
        :cscrm_controls_incorporated_into_ssp_comments,
        :comments,
        clearly_defined_roles: [],
        identified_assets_and_essential_functions: [],
        considerations_in_procurement_processes: [],
        cybersecurity_supply_chain_risk_considerations: [],
        conducts_scra_for_prioritized_products_and_services: [],
      )
    end
  end
end
