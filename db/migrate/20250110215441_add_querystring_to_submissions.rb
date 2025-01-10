class AddQuerystringToSubmissions < ActiveRecord::Migration[7.2]
  def change
    add_column :submissions, :query_string, :text, default: nil, limit: 2048
  end
end
