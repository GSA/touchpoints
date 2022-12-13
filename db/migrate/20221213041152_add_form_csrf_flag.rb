class AddFormCsrfFlag < ActiveRecord::Migration[7.0]
  def change
    add_column :forms, :verify_csrf, :boolean, default: true

    Form.update_all(verify_csrf: false)
  end
end
