class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable

  belongs_to :organization, optional: true
  has_many :touchpoints, through: :organization
  has_many :user_services
  has_many :services, through: :user_services

  APPROVED_DOMAINS = [".gov", ".mil"]

  validates :email, presence: true, if: :tld_check

  def tld_check
    unless APPROVED_DOMAINS.any? { |word| email.end_with?(word) }
      errors.add(:email, "is not from a valid TLD - .gov and .mil domains only")
      return false
    end

    # Call this from here, because I want to hard return if email fails.
    # Specifying `ensure_organization` as validator
    #  ran every time (even when email was not valid), which was undesirable
    ensure_organization
  end

  def ensure_organization
    address = Mail::Address.new(self.email)

    if org = Organization.find_by_domain(address.domain)
      self.organization_id = org.id
    else
      errors.add(:organization, "#{address.domain} is not a valid organization - Please contact Feedback Analytics Team for assistance")
    end
  end

  def organization_name
    if organization.present?
      organization.name
    elsif admin?
      "Admin"
    end
  end

  # TODO - remove this overriding behavior that disabled email sending
  #        once Touchpoints has an email account and config setup
  def send_confirmation_notification?
    # Explicitly confirm the User's account
    self.confirmed_at = Time.now

    return false
  end
end
