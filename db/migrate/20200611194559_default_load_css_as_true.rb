class DefaultLoadCssAsTrue < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:forms, :load_css, true)
  end
end
