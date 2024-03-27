class DefaultCsrfOff < ActiveRecord::Migration[7.1]
  def change
    change_column_default(:forms, :verify_csrf, false)
  end
end
