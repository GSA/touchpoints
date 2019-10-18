class AddModalButtonTextToForm < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :modal_button_text, :string
  end
end
