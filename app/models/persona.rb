# frozen_string_literal: true

class Persona < ApplicationRecord
  validates :name, presence: true

  has_paper_trail

  def websites
    Website.tagged_with(id, on: :personas)
  end
end
