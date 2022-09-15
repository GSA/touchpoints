# frozen_string_literal: true

class Objective < ApplicationRecord
  belongs_to :organization
  belongs_to :goal, counter_cache: true

  acts_as_taggable_on :tags

  validates :name, presence: true

  def organization_name
    organization ? organization.name : nil
  end
end
