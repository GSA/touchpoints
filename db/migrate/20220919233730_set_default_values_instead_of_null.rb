class SetDefaultValuesInsteadOfNull < ActiveRecord::Migration[7.0]
  def change
    change_column_default :service_providers, :inactive, true
    change_column_default :users, :inactive, false

    change_column_null(:service_providers, :inactive, false)
    change_column_null(:users, :inactive, false)

    ServiceProvider.where("inactive ISNULL").each do |provider|
      provider.update(inactive: false)
    end
    
    User.where("inactive ISNULL").each do |provider|
      provider.update(inactive: false)
    end
  end
end
