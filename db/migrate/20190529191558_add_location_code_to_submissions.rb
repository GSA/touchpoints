class AddLocationCodeToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :location_code, :string
  end
end
