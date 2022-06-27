class AddUrlToService < ActiveRecord::Migration[6.1]
  def change
    add_column :services, :url, :string, default: ""
  end
end
