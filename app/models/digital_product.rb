class DigitalProduct < ApplicationRecord
  has_many :digital_product_versions
  belongs_to :user
  belongs_to :organization
end
