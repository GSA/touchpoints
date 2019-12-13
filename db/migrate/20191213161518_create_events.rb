class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.string :object_type # the class of the model object being acted on, if present
      t.integer :object_id  # the instance id of the model object being acted on, if present
      t.string :description, null: false
      t.integer :user_id #the current logged in user, if present, when the event was triggered
      t.timestamps
    end
  end
end