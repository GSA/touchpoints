class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable

  belongs_to :organization, optional: true
  has_many :touchpoints, through: :organization

  APPROVED_DOMAINS = [".gov", ".mil"]

  validates :email, presence: true, if: :tld_check

  def tld_check
    unless APPROVED_DOMAINS.any? { |word| email.end_with?(word)}
      errors.add(:email, "is not from a valid TLD - .gov and .mil domains only")
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
    self.confirm

    return false
  end
end
