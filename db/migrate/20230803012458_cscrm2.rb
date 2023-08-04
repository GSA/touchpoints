class Cscrm2 < ActiveRecord::Migration[7.0]
  def change
    create_table :cscrm_data_collections2 do |t|
      # Question 1
      t.string :interdisciplinary_team
      t.text :interdisciplinary_team_comments

      t.string :pmo_established
      t.text :pmo_established_comments

      t.string :established_policy
      t.text :established_policy_comments

      t.string :supply_chain_acquisition_procedures
      t.text :supply_chain_acquisition_procedures_comments

      # Question 5
      t.string :funding
      t.text :funding_comments

      t.string :identified_staff
      t.text :identified_staff_comments

      t.string :strategy_plan
      t.text :strategy_plan_comments

      t.string :governance_structure
      t.text :governance_structure_comments

      t.string :clearly_defined_roles
      t.text :clearly_defined_roles_comments

      # Question 10
      t.string :identified_assets_and_essential_functions
      t.text :identified_assets_and_essential_functions_comments

      t.string :prioritization_process
      t.text :prioritization_process_comments

      t.string :considerations_in_procurement_processes
      t.text :considerations_in_procurement_processes_comments

      t.string :documented_methodology
      t.text :documented_methodology_comments

      t.string :conducts_scra_for_prioritized_products_and_services
      t.text :conducts_scra_for_prioritized_products_and_services_comments

      # Question 15
      t.string :personnel_required_to_complete_training
      t.text :personnel_required_to_complete_training_comments

      t.string :established_process_information_sharing_with_fasc
      t.text :established_process_information_sharing_with_fasc_comments

      t.string :cybersecurity_supply_chain_risk_considerations
      t.text :cybersecurity_supply_chain_risk_considerations_comments

      t.string :process_for_product_authenticity
      t.text :process_for_product_authenticity_comments

      t.string :cscrm_controls_incorporated_into_ssp
      t.text :cscrm_controls_incorporated_into_ssp_comments

      t.text :comments

      t.integer :organization_id
      t.integer :bureau_id
      t.string :year
      t.string :quarter
      t.integer :user_id
      t.string :integrity_hash
      t.string :aasm_state
      t.text :reflection
      t.string :rating

      t.timestamps
    end

    add_index :cscrm_data_collections2, :organization_id
    add_index :cscrm_data_collections2, :user_id
  end
end
