class PraContact < ApplicationRecord
  belongs_to :organization, optional: true
  validates :email, presence: true
end
