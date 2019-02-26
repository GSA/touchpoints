class AddExpirationDateToTouchpoint < ActiveRecord::Migration[5.2]
  def change
    add_column :touchpoints, :expiration_date, :date
  end
end
