class AddHttpsToWebsites < ActiveRecord::Migration[6.1]
  def change
    add_column :websites, :https, :boolean
  end
end
