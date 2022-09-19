# frozen_string_literal: true

class ServiceProvider < ApplicationRecord
  resourcify
  belongs_to :organization
  has_many :services
  has_many :collections, through: :services
  acts_as_taggable_on :tags

  validates :name, presence: true
  validates :slug, presence: true

  scope :active, -> { where('inactive = false') }

  def service_provider_managers
    User.with_role(:service_provider_manager, self)
  end

  def organization_name
    organization ? organization.name : nil
  end

  def organization_abbreviation
    organization ? organization.abbreviation : nil
  end
end
