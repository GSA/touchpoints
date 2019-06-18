class AddDeliveryMethodToTouchpoints < ActiveRecord::Migration[5.2]
  def change
    add_column :touchpoints, :delivery_method, :string
    add_column :touchpoints, :element_selector, :string
  end
end
