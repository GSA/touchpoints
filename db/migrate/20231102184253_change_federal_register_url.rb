class ChangeFederalRegisterUrl < ActiveRecord::Migration[7.1]
  def change
    change_column :cx_collection_details, :federal_register_url, :string
  end
end
