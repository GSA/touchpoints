class DigitalServiceAccount < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  validates :account, presence: true

  def organization_name
    self.organization.name
  end

  def organization_abbreviation
    self.organization.abbreviation
  end
end
