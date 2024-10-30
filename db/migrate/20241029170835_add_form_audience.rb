class AddFormAudience < ActiveRecord::Migration[7.2]
  def change
    add_column :forms, :audience, :string, default: "public", comment: "indicates whether a form is intended for a public or internal audience"
  end
end
