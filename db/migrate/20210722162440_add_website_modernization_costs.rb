class AddWebsiteModernizationCosts < ActiveRecord::Migration[6.1]
  def change
    add_column :websites, :modernization_cost_2021, :float
    add_column :websites, :modernization_cost_2022, :float
    add_column :websites, :modernization_cost_2023, :float
  end
end
