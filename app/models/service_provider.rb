class ServiceProvider < ApplicationRecord
  resourcify
  belongs_to :organization
  has_many :services
  has_many :collections, through: :services
  acts_as_taggable_on :tags

  validates :slug, presence: true

  scope :active, -> { where("inactive ISNULL or inactive = false") }

  def service_provider_managers
    User.with_role(:service_provider_manager, self)
  end
  
  def organization_name
    self.organization ? self.organization.name : nil
  end
end
