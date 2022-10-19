class AddDigitalServiceFields < ActiveRecord::Migration[7.0]
  def change
    add_column :services, :digital_service, :boolean, default: false
    add_column :services, :estimated_annual_volume_of_customers, :integer, default: 0
  end
end
