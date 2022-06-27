class MoveHispToService < ActiveRecord::Migration[6.1]
  def change
    add_column :services, :hisp, :boolean, default: false

    # For OMB CX Reporting
    add_column :services, :department, :string, default: ''
    add_column :services, :bureau, :string, default: ''
    add_column :services, :bureau_abbreviation, :string, default: ''
    add_column :services, :service_abbreviation, :string, default: ''
    add_column :services, :service_slug, :string, default: ''

    remove_column :forms, :hisp

    Service.update_all(hisp: false)
  end
end
