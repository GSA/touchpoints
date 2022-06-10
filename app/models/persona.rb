class Persona < ApplicationRecord
  validates :name, presence: true

  has_paper_trail

  def websites
    Website.tagged_with(self.id, on: :personas)
  end
end
