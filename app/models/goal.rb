class Goal < ApplicationRecord
  belongs_to :organization
  has_many :milestones

  validates :name, presence: true
end
