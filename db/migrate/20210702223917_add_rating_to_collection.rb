# frozen_string_literal: true

class AddRatingToCollection < ActiveRecord::Migration[6.1]
  def change
    add_column :collections, :rating, :string
  end
end
