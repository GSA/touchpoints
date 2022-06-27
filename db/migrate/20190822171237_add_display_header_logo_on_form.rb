class AddDisplayHeaderLogoOnForm < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :display_header_logo, :boolean, default: false
  end
end
