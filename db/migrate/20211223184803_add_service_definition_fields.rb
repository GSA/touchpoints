class AddServiceDefinitionFields < ActiveRecord::Migration[6.1]
  def change
    add_column :services, :justification_text, :text
    add_column :services, :where_customers_interact, :text
    add_column :services, :kind, :string
  end
end
