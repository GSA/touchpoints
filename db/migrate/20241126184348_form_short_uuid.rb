class FormShortUuid < ActiveRecord::Migration[7.2]
  def change
    add_column :forms, :short_uuid, :string, limit: 8
    add_index :forms, :short_uuid, unique: true

    remove_index :forms, :uuid
    add_index :forms, :uuid, unique: true

    remove_index :submissions, :uuid
    add_index :submissions, :uuid, unique: true

    Form.all.each do |form|
      form.update({
        short_uuid: form.uuid[0..7]
      })
    end
  end
end
