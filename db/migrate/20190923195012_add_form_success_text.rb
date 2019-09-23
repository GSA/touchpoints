class AddFormSuccessText < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :success_text, :text
  end
end
