# frozen_string_literal: true

class EnsureUniqueUserRoles < ActiveRecord::Migration[7.0]
  def change
    add_index :user_roles, %i[user_id form_id], unique: true
  end
end
