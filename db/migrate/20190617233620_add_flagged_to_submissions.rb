class AddFlaggedToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :flagged, :boolean, default: false
  end
end
