class AddServiceCxCollectionCount < ActiveRecord::Migration[7.2]
  def change
    add_column :services, :cx_collections_count, :integer, default: 0
    Service.all.each do |service|
      service.update(cx_collections_count: service.cx_collections.size)
    end
  end
end
