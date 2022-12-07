# frozen_string_literal: true
require 'csv'

class CscrmDataCollection < ApplicationRecord
  belongs_to :organization

  validates :year, presence: true
  validates :quarter, presence: true

  def self.to_csv
    collections = CscrmDataCollection.order('year, quarter')

    example_attributes = CscrmDataCollection.new.attributes
    attributes = example_attributes.keys

    CSV.generate(headers: true) do |csv|
      csv << attributes

      collections.each do |collection|
        csv << attributes.map { |attr| collection.send(attr) }
      end
    end
  end

end
