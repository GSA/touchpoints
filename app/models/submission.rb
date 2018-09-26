class Submission < ApplicationRecord
  belongs_to :organization
  belongs_to :touchpoint

  validates :first_name, presence: true
end
