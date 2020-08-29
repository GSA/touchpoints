class AddOccasionToForm < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :occasion, :string
  end
end
