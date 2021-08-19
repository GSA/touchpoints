class Website < ApplicationRecord
  validates :domain, presence: true
  validates :domain, uniqueness: true
  validates :type_of_site, presence: true

  belongs_to :organization, optional: true

  scope :active, -> { where("production_status = 'Production' OR production_status = 'Staging'") }

  PRODUCTION_STATUSES = [
    "Archived",
    "Decommissioned",
    "Production",
    "Redirect",
    "Staging"
  ]

  ACTIVE_PRODUCTION_STATUSES = [
    "Production",
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

    user.admin? || user.organizational_website_manager || self.contact_email == user.email || self.site_owner_email == user.email
  end

  def blankFields
    Website.column_names.select { | cn | self.send(cn).blank? }
  end

  def requiresDataCollection?
    blankFields.size > 0
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
