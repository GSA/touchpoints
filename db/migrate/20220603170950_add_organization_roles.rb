# frozen_string_literal: true

class AddOrganizationRoles < ActiveRecord::Migration[7.0]
  def change
    create_table(:organizations_roles, id: false) do |t|
      t.references :organization
      t.references :role
    end

    add_index(:organizations_roles, %i[organization_id role_id])
  end
end
