class DigitalProductVersion < ApplicationRecord
  belongs_to :digital_product

  validates_presence_of :platform
  validates_presence_of :version_number
end
