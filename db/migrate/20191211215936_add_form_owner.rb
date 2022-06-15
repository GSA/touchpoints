# frozen_string_literal: true

class AddFormOwner < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :user_id, :integer
    add_column :forms, :template, :boolean, default: false
  end
end
