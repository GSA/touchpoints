class AddContactCenterToService < ActiveRecord::Migration[7.0]
  def change
    add_column "services", :contact_center, :boolean, default: false
  end
end
