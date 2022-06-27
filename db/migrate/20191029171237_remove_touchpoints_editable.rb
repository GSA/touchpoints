# frozen_string_literal: true

class RemoveTouchpointsEditable < ActiveRecord::Migration[5.2]
  def change
    remove_column :touchpoints, :editable
  end
end
