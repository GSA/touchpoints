class AddNewFlagToServiceProvider < ActiveRecord::Migration[6.1]
  def change
    add_column :service_providers, :new, :boolean
  end
end
