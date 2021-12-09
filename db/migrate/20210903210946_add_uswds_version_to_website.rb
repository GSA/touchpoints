class AddUswdsVersionToWebsite < ActiveRecord::Migration[6.1]
  def change
    add_column :websites, :uswds_version, :string
  end
end
