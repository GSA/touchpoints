class AddCscrmCommentFields < ActiveRecord::Migration[7.0]
  def change
    add_column :cscrm_data_collections, :agency_roles, :string

    add_column :cscrm_data_collections, :agency_roles_comments, :text
    add_column :cscrm_data_collections, :stakeholder_champion_identified_comments, :text
    add_column :cscrm_data_collections, :interdisciplinary_team_established_comments, :text
    add_column :cscrm_data_collections, :pmo_established_comments, :text
    add_column :cscrm_data_collections, :agency_wide_scrm_strategy_and_implementation_plan_comments, :text
    add_column :cscrm_data_collections, :enterprise_risk_management_function_established_comments, :text
    add_column :cscrm_data_collections, :roles_and_responsibilities_comments, :text
    add_column :cscrm_data_collections, :enterprise_wide_scrm_policy_established_comments, :text
    add_column :cscrm_data_collections, :funding_for_initial_operating_capability_comments, :text
    add_column :cscrm_data_collections, :staffing_comments, :text
    add_column :cscrm_data_collections, :missions_identified_comments, :text
    add_column :cscrm_data_collections, :prioritization_process_comments, :text
    add_column :cscrm_data_collections, :considerations_in_procurement_processes_comments, :text
    add_column :cscrm_data_collections, :conducts_scra_for_prioritized_products_and_services_comments, :text
    add_column :cscrm_data_collections, :established_process_information_sharing_with_fasc_comments, :text
    add_column :cscrm_data_collections, :general_comments, :text

    remove_column :cscrm_data_collections, :missions_identified_why_not, :text



  end
end
