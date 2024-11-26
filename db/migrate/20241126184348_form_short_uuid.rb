class FormShortUuid < ActiveRecord::Migration[7.2]
  def change
    add_column :forms, :short_uuid, :string, limit: 8
    add_index :forms, :short_uuid

    Form.all.each do |form|
      form.update(:short_uuid, uuid[0..7])
    end
  end
end
