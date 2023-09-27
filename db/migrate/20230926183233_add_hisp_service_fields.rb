class AddHispServiceFields < ActiveRecord::Migration[7.0]
  def change
    add_column :services, :year_designated, :integer
    add_column :services, :short_description, :text
  end
end
