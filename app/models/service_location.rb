class ServiceLocation < ApplicationRecord
  belongs_to :organization

  validates :abbreviation, uniqueness: { scope: :organization_id,
    message: "Location must be unique within an Organization" }
end
