# frozen_string_literal: true

module Admin
  class CscrmDataCollectionsController < AdminController
    before_action :set_cscrm_data_collection, only: %i[show edit update destroy]

    def index
      respond_to do |format|
        format.html {
          @cscrm_data_collections = CscrmDataCollection.all
        }
        format.csv {
          ensure_admin
          csv_content = CscrmDataCollection.to_csv
          send_data csv_content
        }
      end
    end

    def show; end

    def new
      @cscrm_data_collection = CscrmDataCollection.new
    end

    def edit; end

    def create
      @cscrm_data_collection = CscrmDataCollection.new(cscrm_data_collection_params)

      respond_to do |format|
        if @cscrm_data_collection.save
          format.html { redirect_to admin_cscrm_data_collection_url(@cscrm_data_collection), notice: 'Cscrm data collection was successfully created.' }
          format.json { render :show, status: :created, location: @cscrm_data_collection }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @cscrm_data_collection.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @cscrm_data_collection.update(cscrm_data_collection_params)
          format.html { redirect_to admin_cscrm_data_collection_url(@cscrm_data_collection), notice: 'Cscrm data collection was successfully updated.' }
          format.json { render :show, status: :ok, location: @cscrm_data_collection }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @cscrm_data_collection.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @cscrm_data_collection.destroy

      respond_to do |format|
        format.html { redirect_to cscrm_data_collections_url, notice: 'Cscrm data collection was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private

    def set_cscrm_data_collection
      @cscrm_data_collection = CscrmDataCollection.find(params[:id])
    end

    def cscrm_data_collection_params
      params.require(:cscrm_data_collection).permit(
        :user_id,
        :organization_id,
        :year,
        :quarter,
        :leadership_roles,
        :stakeholder_champion_identified,
        :pmo_established,
        :interdisciplinary_team_established,
        :enterprise_risk_management_function_established,
        :enterprise_wide_scrm_policy_established,
        :agency_wide_scrm_strategy_and_implementation_plan_established,
        :funding_for_initial_operating_capability,
        :staffing,
        :missions_identified_why_not,
        :prioritization_process,
        :established_process_information_sharing_with_fasc,
        :rating,
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
