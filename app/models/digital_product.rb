class DigitalProduct < ApplicationRecord
  belongs_to :user
  belongs_to :organization
  has_many :digital_product_versions
end
