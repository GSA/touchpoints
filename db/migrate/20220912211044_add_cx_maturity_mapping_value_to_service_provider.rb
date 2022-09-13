class AddCxMaturityMappingValueToServiceProvider < ActiveRecord::Migration[7.0]
  def change
    add_column :service_providers, :cx_maturity_mapping_value, :integer, default: 0

    # add counter cache
    add_column :service_providers, :services_count, :integer, default: 0
    ServiceProvider.all.each do |provider|
      ServiceProvider.reset_counters(provider.id, :services)
    end

  end
end
