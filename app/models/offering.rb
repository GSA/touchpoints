class Offering < ApplicationRecord
  belongs_to :service, optional: true

  acts_as_taggable_on :personas

  def offering_personas
    Persona.where(id: self.persona_list)
  end
end