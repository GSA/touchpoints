class AddCscrmFields < ActiveRecord::Migration[7.0]
  def change
    add_column :cscrm_data_collections, :bureau, :string
    add_column :cscrm_data_collections, :leadership_roles_comments, :text
    add_column :cscrm_data_collections, :personnel_required_comments, :text
    add_column :cscrm_data_collections, :cybersecurity_supply_chain_risk_comments, :text
  end
end
