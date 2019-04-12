class Service < ApplicationRecord
  belongs_to :organization
  validates :name, presence: true
end
