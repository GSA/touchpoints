class AddOrganizationCfoActFlag < ActiveRecord::Migration[7.0]
  def change
    add_column :organizations, :cfo_act_agency, :boolean, default: false
    add_column :organizations, :parent_id, :integer, default: nil
  end
end
