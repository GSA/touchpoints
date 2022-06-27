class AddHostingPlatformToWebsites < ActiveRecord::Migration[6.1]
  def change
    add_column :websites, :hosting_platform, :string
  end
end
