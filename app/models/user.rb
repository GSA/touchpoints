class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable

  belongs_to :organization, optional: true
  has_many :touchpoints, through: :organization

  def admin?
    email == "admin@example.com"
  end
end
