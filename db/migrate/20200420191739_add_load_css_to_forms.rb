class AddLoadCssToForms < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :load_css, :boolean, default: false

    Form.all.each do |form|
      form.update_attribute(:load_css, true)
    end
  end
end
