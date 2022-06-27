class AddDigitalProductName < ActiveRecord::Migration[7.0]
  def change
    add_column :digital_products, :name, :string
  end
end
