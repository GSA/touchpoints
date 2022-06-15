# frozen_string_literal: true

class AddEditableToTouchpoints < ActiveRecord::Migration[5.2]
  def change
    add_column :touchpoints, :editable, :boolean, default: true
  end
end
