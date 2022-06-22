# frozen_string_literal: true

class DigitalProductVersion < ApplicationRecord
  belongs_to :digital_product

  validates :platform, presence: true
  validates :version_number, presence: true
end
