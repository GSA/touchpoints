class AddSuccessTextHeadingToForms < ActiveRecord::Migration[6.1]
  def change
    add_column :forms, :success_text_heading, :string

    Form.update_all(success_text_heading: "Success")
  end
end
