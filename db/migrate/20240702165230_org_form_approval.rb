class OrgFormApproval < ActiveRecord::Migration[7.1]
  def change
    add_column :organizations, :form_approval_enabled, :boolean, default: false, comment: "Indicate whether this organization requires a Submission and Approval process for forms"
  end
end
