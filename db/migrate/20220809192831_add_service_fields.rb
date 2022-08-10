class AddServiceFields < ActiveRecord::Migration[7.0]
  def change
    add_column :services, :homepage_url, :string

    # the primary budget account code that is best associated with activities associated this service
    add_column :services, :budget_code, :string

    # the primary unique IT Investment identifier for the primary IT investment associated with this service; Example xxx-99999XXXX
    add_column :services, :uii_code, :string

    add_column :services, :transactional, :boolean, default: false
  end
end
