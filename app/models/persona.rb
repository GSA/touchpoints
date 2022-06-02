class Persona < ApplicationRecord
  belongs_to :user

  validates :name, presence: true

  has_paper_trail
end
