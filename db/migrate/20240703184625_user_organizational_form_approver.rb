class UserOrganizationalFormApprover < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :organizational_form_approver, :boolean, default: false
  end
end
