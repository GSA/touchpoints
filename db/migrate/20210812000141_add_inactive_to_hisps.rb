class AddInactiveToHisps < ActiveRecord::Migration[6.1]
  def change
    add_column :service_providers, :inactive, :boolean
  end
end
