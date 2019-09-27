class AddHispToService < ActiveRecord::Migration[5.2]
  def change
    add_column :services, :hisp, :boolean, default: false
  end
end
