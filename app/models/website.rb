class Website < ApplicationRecord
  validates :domain, presence: true

  scope :active, -> { where("production_status = 'Production' OR production_status = 'Redirect' OR production_status = 'Staging'") }

  PRODUCTION_STATUSES = [
    "Archived",
    "Decommissioned",
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
