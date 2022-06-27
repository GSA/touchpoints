class AddTimeZoneToForm < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :time_zone, :string, default: "Eastern Time (US & Canada)"
  end
end
