class AddNotificationFrequencyToForm < ActiveRecord::Migration[6.1]
  def change
    add_column :forms, :notification_frequency, :string, default: 'instant'
  end
end
