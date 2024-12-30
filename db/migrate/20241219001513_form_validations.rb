class FormValidations < ActiveRecord::Migration[7.2]
  def change
    add_column :forms, :enforce_new_submission_validations, :boolean, default: true
    Form.update_all(enforce_new_submission_validations: false)
  end
end
