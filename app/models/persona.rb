class Persona < ApplicationRecord

  validates :name, presence: true

  has_paper_trail
end
