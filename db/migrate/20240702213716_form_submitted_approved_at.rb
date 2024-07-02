class FormSubmittedApprovedAt < ActiveRecord::Migration[7.1]
  def change
    add_column :forms, :submitted_at, :datetime
    add_column :forms, :approved_at, :datetime
  end
end
