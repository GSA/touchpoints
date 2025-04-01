class AppendIdToSuccessText < ActiveRecord::Migration[8.0]
  def change
    add_column :forms, :append_id_to_success_text, :boolean, default: false, comment: "Set to true to append a response ID to the form's success_text"
  end
end
