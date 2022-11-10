class CreateCscrmDataCollections < ActiveRecord::Migration[7.0]
  def change
    create_table :cscrm_data_collections do |t|
      t.string :leadership_roles
      t.string :stakeholder_champion_identified
      t.string :pmo_established
      t.string :interdisciplinary_team_established
      t.string :enterprise_risk_management_function_established
      t.string :enterprise_wide_scrm_policy_established
      t.string :agency_wide_scrm_strategy_and_implementation_plan_established
      t.string :funding_for_initial_operating_capability
      t.string :staffing
      t.string :roles_and_responsibilities
      t.text :missions_identified
      t.text :missions_identified_why_not
      t.text :prioritization_process
      t.string :considerations_in_procurement_processes
      t.string :conducts_scra_for_prioritized_products_and_services
      t.string :personnel_required_to_complete_training
      t.string :established_process_information_sharing_with_fasc
      t.string :cybersecurity_supply_chain_risk_considerations

      t.integer :organization_id
      t.string :year
      t.string :quarter
      t.integer :user_id
      t.string :integrity_hash
      t.string :aasm_state
      t.text :reflection
      t.string :rating

      t.timestamps
    end

    add_index :cscrm_data_collections, :organization_id
    add_index :cscrm_data_collections, :user_id
  end
end
