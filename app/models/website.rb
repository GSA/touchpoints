class Website < ApplicationRecord
  include AASM

  validates :domain, presence: true
  validates :domain, uniqueness: true
  validates :type_of_site, presence: true

  belongs_to :organization, optional: true

  scope :active, -> { where("production_status = 'Production' OR production_status = 'production' OR production_status = 'Staging' OR production_status = 'newly_requested'") }

  PRODUCTION_STATUSES = {
    "newly_requested" => "Newly requested",
    "request_approved" => "Request approved",
    "request_denied" => "Request denied",
    "in_development" => "In development",
    "production" => "Production",
    "redirect" => "Redirect",
    "archived" => "Archived",
    "decommissioned" => "Decommissioned",
  }

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

  aasm :production_status do
    state :newly_requested, initial: true
    state :request_approved
    state :request_denied
    state :in_development
    state :production
    state :redirect
    state :archived
    state :decommissioned

    event :approve do
      transitions from: [:newly_requested], to: :request_approved
    end
    event :deny do
      transitions from: [:newly_requested], to: :request_denied
    end
    event :start_development do
      transitions from: [:request_approved], to: :in_development
    end
    event :launch do
      transitions from: [:in_development], to: :production
    end
    event :redirect do
      transitions from: [:production], to: :redirect
    end
    event :archive do
      transitions from: [:production, :archived], to: :decommissioned
    end
    event :decommission do
      transitions from: [:decommissioned], to: :newly_requested
    end
  end

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
