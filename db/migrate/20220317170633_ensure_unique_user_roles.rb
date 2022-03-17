class EnsureUniqueUserRoles < ActiveRecord::Migration[7.0]
  def change
    add_index :user_roles, [:user_id, :form_id], unique: true
  end
end
