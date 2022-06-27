class AddRepositoryUrlToWebsites < ActiveRecord::Migration[6.1]
  def change
    add_column :websites, :repository_url, :string
  end
end
