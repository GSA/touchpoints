require 'open-uri'

class Website < ApplicationRecord
  include AASM

  validates :domain, presence: true
  validates :domain, uniqueness: true
  validate :validate_domain_format
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

  TYPE_OF_SITES = {
    "API"                     => "Application Programming Interface",
    "Application"             => "Transactional site (web app/back-end system) with some front-end web content",
    "Application Login"       => "Login page to a back-end system",
    "Critical infrastructure" => "Required to support a GSA or shared service",
    "GitHub repo"             => "Site decommissioned; URL redirects to a GitHub repo (status is redirect)",
    "Google form"             => "Site redirects to a Google form (status is redirect)",
    "Informational"           => "Informational (not transactional) site"
  }

  DIGITAL_BRAND_CATEGORIES = {
    "GSA Business" => "About a GSA program, product, or service",
    "Hybrid"       => "Managed by GSA in partnership with another agency or business partner; gov-wide or collaborative",
    "External"     => "Managed by GSA on behalf of another agency or business partner; not related to GSA business"
  }

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

  def validate_domain_format
    if self.domain.present? && !self.domain.include?(".")
      errors.add(:domain, "domain must have a suffix, like .gov or .mil")
    end
  end

  def site_scanner_json_request
    begin
      url = "https://api.gsa.gov/technology/site-scanning/v1/websites/#{self.domain}?api_key=#{ENV.fetch("API_DATA_GOV_KEY")}&limit=10"
      text = URI.open(url).read
    rescue => e
      "Error during Site Scanner API request for #{self.domain}.\n\n#{e}"
    end
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
