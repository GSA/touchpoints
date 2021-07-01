class Website < ApplicationRecord
  validates :domain, presence: true
  validates :type_of_site, presence: true

  belongs_to :organization, optional: true

  scope :active, -> { where("production_status = 'Production' OR production_status = 'Redirect' OR production_status = 'Staging'") }

  PRODUCTION_STATUSES = [
    "Archived",
    "Decommissioned",
    "Production",
    "Redirect",
    "Staging"
  ]

  ACTIVE_PRODUCTION_STATUSES = [
    "Production",
    "Redirect",
    "Staging"
  ]

  TYPE_OF_SITES = [
    "Application",
    "Application Login",
    "API",
    "Critical infrastructure",
    "GitHub repo",
    "Google form",
    "Informational"
  ]

  DIGITAL_BRAND_CATEGORIES = [
    "GSA Business",
    "Hybrid",
    "External"
  ]

  def admin?(user:)
    raise ArgumentException unless user.class == User

    user.admin? || self.contact_email == user.email || self.site_owner_email == user.email
  end

  def self.to_csv
    websites = Website.all
    header_attributes = websites.first.attributes.keys || []

    CSV.generate(headers: true) do |csv|
      csv << header_attributes

      websites.each do |website|
        csv << website.attributes.values
      end
    end
  end
end
