class TouchpointAddUuid < ActiveRecord::Migration[5.2]
  def change
  	add_column :touchpoints, :uuid, :string
  	add_index :touchpoints, :uuid
  	Touchpoint.find_each do |tp|
		tp.uuid = SecureRandom.uuid
		tp.save!
  	end

  end
end
