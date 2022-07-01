# frozen_string_literal: true

class Offering < ApplicationRecord
  belongs_to :service, optional: true

  acts_as_taggable_on :personas

  has_paper_trail

  def offering_personas
    Persona.where(id: persona_list)
  end
end
