# frozen_string_literal: true

class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :lockable
  # :rememberable
  devise :database_authenticatable,
         :trackable,
         :timeoutable

  devise :omniauthable, omniauth_providers: Rails.configuration.x.omniauth.providers

  belongs_to :organization, optional: true
  has_many :user_roles, dependent: :destroy
  has_many :forms, through: :user_roles, primary_key: 'form_id'
  has_many :collections, through: :organization

  validate :api_key_format
  before_save :update_api_key_updated_at

  def update_api_key_updated_at
    self.api_key_updated_at = Time.zone.now if api_key_changed?
  end

  def api_key_format
    errors.add(:api_key, 'is not 40 characters, as expected from api.data.gov.') if api_key.present? && api_key.length != 40
  end

  after_create :send_new_user_notification

  validates :email, presence: true, if: :tld_check

  scope :active, -> { where(inactive: false) }

  scope :admins, -> { where(admin: true) }
  scope :performance_managers, -> { where(performance_manager: true) }
  scope :registry_managers, -> { where(registry_manager: true) }
  scope :service_managers, -> { where(service_manager: true) }
  scope :organizational_website_managers, -> { where(organizational_website_manager: true) }

  def self.admins
    User.where(admin: true)
  end

  def self.from_omniauth(auth)
    # Set login_dot_gov as Provider for legacy TP Devise accounts
    # TODO: Remove once all accounts are migrated/have `provider` and `uid` set
    @existing_user = User.find_by_email(auth.info.email)
    if @existing_user && @existing_user.provider.blank?
      @existing_user.provider = auth.provider
      @existing_user.uid = auth.uid
      @existing_user.save
    end

    # For login.gov native accounts
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 24]
    end
  end

  def tld_check
    unless ENV['GITHUB_CLIENT_ID'].present? || APPROVED_DOMAINS.any? { |word| email.end_with?(word) }
      errors.add(:email, "is not from a valid TLD - #{APPROVED_DOMAINS.to_sentence} domains only")
      return false
    end

    # Call this from here, because I want to hard return if email fails.
    # Specifying `ensure_organization` as validator
    #  ran every time (even when email was not valid), which was undesirable
    ensure_organization
  end

  def organization_name
    if organization.present?
      organization.name
    elsif admin?
      'Admin'
    end
  end

  def role
    if admin?
      'Admin'
    else
      'User'
    end
  end

  # For Devise
  # This determines whether a user is inactive or not
  def active_for_authentication?
    self && !inactive?
  end

  # For Devise
  # This is the flash message shown to a user when inactive
  def inactive_message
    "User account #{email} is inactive. Please contact #{ENV.fetch('TOUCHPOINTS_SUPPORT')}."
  end

  def deactivate!
    update!(inactive: true)
    UserMailer.account_deactivated_notification(self).deliver_later
    Event.log_event(Event.names[:user_deactivated], 'User', id, "User account #{email} deactivated on #{Date.today}")
  end

  def self.send_account_deactivation_notifications(expire_days)
    users = User.deactivation_pending(expire_days)
    users.each do |user|
      UserMailer.account_deactivation_scheduled_notification(user.email, expire_days).deliver_later
    end
  end

  def self.deactivation_pending(expire_days)
    min_time = ((90 - expire_days) + 1).days.ago
    max_time = (90 - expire_days).days.ago
    User.active.where('(current_sign_in_at ISNULL AND created_at BETWEEN ? AND ?) OR (current_sign_in_at BETWEEN ? AND ?)', min_time, max_time, min_time, max_time)
  end

  def self.deactivate_inactive_accounts!
    # Find all accounts scheduled to be deactivated in 14 days
    users = User.active.where('(current_sign_in_at ISNULL AND created_at <= ?) OR (current_sign_in_at <= ?)', 90.days.ago, 90.days.ago)
    users.each(&:deactivate!)
  end

  def self.to_csv
    active_users = order('email')
    return nil if active_users.blank?

    header_attributes = %w[organization_name email current_sign_in_at]
    attributes = active_users.map do |u|
      {
        organization_name: u.organization.name,
        email: u.email,
        current_sign_in_at: u.current_sign_in_at,
      }
    end

    CSV.generate(headers: true) do |csv|
      csv << header_attributes
      attributes.each do |attrs|
        csv << attrs.values
      end
    end
  end


  private

  def parse_host_from_domain(string)
    fragments = string.split('.')
    case fragments.size
    when 2
      string
    when 3
      fragments.shift
      fragments.join('.')
    when 4
      fragments.shift
      fragments.shift
      fragments.join('.')
    end
  end

  def ensure_organization
    return if organization_id.present?

    email_address_domain = Mail::Address.new(email).domain
    parsed_domain = parse_host_from_domain(email_address_domain)

    if org = Organization.find_by_domain(parsed_domain)
      self.organization_id = org.id
    else
      UserMailer.no_org_notification(self).deliver_later if id
      errors.add(:organization, "'#{email_address_domain}' has not yet been configured for Touchpoints - Please contact the Feedback Analytics Team for assistance.")
    end
  end

  def send_new_user_notification
    UserMailer.new_user_notification(self).deliver_later
  end
end
