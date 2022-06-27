class AddDisplayHeaderSquareLogoToForm < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :display_header_square_logo, :boolean
  end
end
