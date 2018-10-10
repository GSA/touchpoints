class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable

  belongs_to :organization, optional: true
  has_many :touchpoints, through: :organization

  # TODO - remove this overriding behavior that disabled email sending
  #        once Touchpoints has an email account and config setup
  def send_confirmation_notification?
    # Explicitly confirm the User's account
    self.confirm

    return false
  end
end
