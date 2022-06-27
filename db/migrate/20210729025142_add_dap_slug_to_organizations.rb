# frozen_string_literal: true

class AddDapSlugToOrganizations < ActiveRecord::Migration[6.1]
  def change
    add_column :organizations, :digital_analytics_path, :string
  end
end
