class AddWebsiteBacklogs < ActiveRecord::Migration[7.0]
  def change
    add_column :websites, :backlog_tool, :string, default: ""
    add_column :websites, :backlog_url, :string, default: ""
  end
end
