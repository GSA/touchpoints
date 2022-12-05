class AddServiceCollectionFields < ActiveRecord::Migration[7.0]
  def change

    add_column :services, :channels, :string, array: true
    add_column :services, :fully_digital_service, :boolean, default: false
    add_column :services, :barriers_to_fully_digital_service, :text
    add_column :services, :multi_agency_service, :boolean, default: false
    add_column :services, :multi_agency_explanation, :text
    add_column :services, :other_service_type, :string
    add_column :services, :customer_volume_explanation, :string
    add_column :services, :resources_needed_to_provide_digital_service, :text
    add_column :services, :bureau_id, :integer
    add_column :services, :office, :string
    add_column :services, :designated_for_improvement_a11_280, :boolean, default: false

    change_column :services, :kind, :string, array: true, using: "(string_to_array(kind, ','))"
    remove_column :services, :potential_solutions_for_digitization
  end
end
