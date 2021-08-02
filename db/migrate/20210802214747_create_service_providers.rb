class CreateServiceProviders < ActiveRecord::Migration[6.1]
  def change
    create_table :service_providers do |t|
      t.integer :organization_id
      t.string :name
      t.text :description
      t.text :notes
      t.string :department
      t.string :department_abbreviation
      t.string :bureau
      t.string :bureau_abbreviation

      t.timestamps
    end

    add_column :services, :service_provider_id, :integer

    Service.all.each do |service|
      ServiceProvider.create!({
        organization_id: service.organization_id,
        name: service.name,
        department: service.department,
        department_abbreviation: service.organization.abbreviation.downcase,
        bureau: service.bureau,
        bureau_abbreviation: service.bureau_abbreviation,
        description: service.description,
        notes: service.notes
      })
    end

  end
end
