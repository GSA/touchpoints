class FormSubmittedApprovedAt < ActiveRecord::Migration[7.1]
  def change
    add_column :forms, :submitted_at, :datetime
    add_column :forms, :approved_at, :datetime

    Form.where(aasm_state: :in_development).update_all(aasm_state: :created)
    Form.where(aasm_state: :live).update_all(aasm_state: :published)
  end
end
