# frozen_string_literal: true

require 'open-uri'

class Website < ApplicationRecord
  resourcify
  acts_as_taggable_on :tags, :personas
  include AASM
  has_paper_trail

  validates :domain, presence: true
  validates :domain, uniqueness: true
  validate :validate_domain_format
  validate :validate_domain_suffix
  validates :type_of_site, presence: true

  belongs_to :organization
  belongs_to :service, optional: true

  scope :active, -> { where("production_status = 'production' OR production_status = 'newly_requested' OR production_status = 'request_approved'") }

  PRODUCTION_STATUSES = {
    'newly_requested' => 'Newly requested',
    'request_approved' => 'Request approved',
    'request_denied' => 'Request denied',
    'in_development' => 'In development',
    'staging' => 'Staging',
    'production' => 'Production',
    'being_decommissioned' => 'Being decommissioned',
    'redirect' => 'Redirect',
    'archived' => 'Archived',
    'decommissioned' => 'Decommissioned',
  }.freeze

  ACTIVE_PRODUCTION_STATUSES = %w[
    Production
    Staging
  ].freeze

  TYPE_OF_SITES = {
    'API' => 'Application Programming Interface',
    'Application' => 'Transactional site (web app/back-end system) with some front-end web content',
    'Application Login' => 'Login page to a back-end system',
    'Critical infrastructure' => 'Required to support an active service',
    'GitHub repo' => 'Site decommissioned; URL redirects to a GitHub repo (status is redirect)',
    'Google form' => 'Site redirects to a Google form (status is redirect)',
    'Informational' => 'Informational (not transactional) site',
    'Other' => 'Other',
  }.freeze

  AUTHENTICATION_TOOLS = {
    'Drupal' => 'Drupal',
    'Google oAuth' => 'Google oAuth',
    'GSA Secure Auth' => 'GSA Secure Auth',
    'Jira' => 'Jira',
    'Login.gov' => 'Login.gov',
    'LDAP' => 'LDAP',
    'Max.gov' => 'Max.gov',
    'Okta' => 'Okta',
    'Salesforce' => 'Salesforce',
    'Custom' => 'Custom',
    'Other' => 'Other',
    'None' => 'None',
  }.freeze

  FEEDBACK_TOOLS = {
    'Drupal' => 'Drupal',
    'Email' => 'Email',
    'GitHub' => 'GitHub',
    'Google Forms' => 'Google Forms',
    'Qualtrics' => 'Qualtrics',
    'Medallia' => 'Medallia',
    'SurveyMonkey' => 'SurveyMonkey',
    'Touchpoints' => 'Touchpoints',
    'Custom' => 'Custom',
    'Other' => 'Other',
    'None' => 'None',
  }.freeze

  DIGITAL_BRAND_CATEGORIES = {
    'GSA Business' => 'About a GSA program, product, or service',
    'Hybrid' => 'Managed by GSA in partnership with another agency or business partner; gov-wide or collaborative',
    'External' => 'Managed by GSA on behalf of another agency or business partner; not related to GSA business',
  }.freeze

  aasm :production_status do
    state :newly_requested, initial: true
    state :request_approved
    state :request_denied
    state :in_development
    state :staging
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
    event :stage do
      transitions from: %i[in_development request_approved], to: :staging
    end
    event :launch do
      transitions from: %i[in_development staging], to: :production
    end
    event :redirect do
      transitions from: [:production], to: :redirect
    end
    event :archive do
      transitions from: %i[staging production], to: :archived
    end
    event :decommission do
      transitions from: %i[staging production archived redirect], to: :decommissioned
    end
    event :reset do
      transitions to: :newly_requested
    end
  end

  def transitionable_states
    aasm(:production_status).states(permitted: true)
  end

  def website_managers
    User.with_role(:website_manager, self)
  end

  def website_personas
    Persona.where(id: persona_list)
  end

  def website_manager_emails
    website_managers.collect(&:email).join(', ')
  end

  # return all website_ids managed by users with email matching search string
  def self.ids_by_manager_search(search_text)
    sql = "
      select w.id from websites w, users_roles ur, roles r, users u
      where u.email ilike :search_text
        and u.id = ur.user_id
        and ur.role_id = r.id
        and r.resource_type = 'Website'
        and r.resource_id = w.id
        and r.name = 'website_manager'".gsub("\n", '')
    find_by_sql([sql, { search_text: }]).collect(&:id)
  end

  def admin?(user:)
    raise ArgumentException unless user.instance_of?(User)

    user.admin? ||
      user.organizational_website_manager ||
      contact_email == user.email ||
      site_owner_email == user.email
  end

  def blankFields
    Website.column_names.select { |cn| send(cn).blank? }
  end

  def requiresDataCollection?
    blankFields.size.positive?
  end

  def validate_domain_format
    errors.add(:domain, 'must be formatted as a domain') unless domain.present? && domain.split('.').size >= 2
  end

  def validate_domain_suffix
    errors.add(:domain, 'domain must have a valid suffix, like .gov or .mil') unless domain.present? && APPROVED_DOMAINS.any? { |word| domain.end_with?(word) }
  end

  def site_scanner_json_request
    url = "https://api.gsa.gov/technology/site-scanning/v1/websites/#{domain}?api_key=#{ENV.fetch('API_DATA_GOV_KEY')}&limit=10"
    text = URI.open(url).read
  rescue StandardError => e
    "Error during Site Scanner API request for #{domain}.\n\n#{e}"
  end

  def parent_domain
    return nil unless domain?

    domain.split('.')[-2..].join('.')
  end

  # has a domain name and suffix
  def tld?
    domain.split('.').size == 2
  end

  def self.to_csv
    websites = Website.all
    header_attributes = websites.first.attributes.keys || []

    CSV.generate(headers: true, force_quotes: true) do |csv|
      csv << header_attributes

      websites.each do |website|
        csv << website.attributes.values
      end
    end
  end
end
