class ReflectionTextText < ActiveRecord::Migration[6.1]
  def change
    change_column :collections, :reflection, :text
  end
end
