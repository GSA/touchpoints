class AddIpAddressToggleOnOrganizations < ActiveRecord::Migration[6.1]
  def change
    add_column :organizations, :enable_ip_address, :boolean, default: true

    Organization.all.each do |org|
      org.update({ enable_ip_address: true })
    end
  end
end
