# frozen_string_literal: true

class ServiceProvider < ApplicationRecord
  resourcify
  belongs_to :organization
  has_many :services
  has_many :collections, through: :services
  has_many :omb_cx_reporting_collections, through: :collections
  acts_as_taggable_on :tags

  validates :name, presence: true
  validates :slug, presence: true

  scope :active, -> { where('inactive = false') }

  def service_provider_managers
    User.with_role(:service_provider_manager, self)
  end

  def organization_name
    organization.name
  end

  def organization_abbreviation
    organization.abbreviation
  end

  def self.to_csv
     CSV.generate(headers: true) do |csv|
      csv << %i[
        department
        department_abbreviation
        service_provider_id
        name
        description
        notes
        new_hisp
        inactive
        url
        services_count
        portfolio_manager_email
      ]

      ServiceProvider.active
        .includes(:organization)
        .order('organizations.name', :name).each do |provider|
        csv << [
          provider.organization.name,
          provider.organization.abbreviation.downcase,
          provider.slug,
          provider.name,
          provider.description,
          provider.notes,
          provider.new,
          provider.inactive,
          provider.url,
          provider.services_count,
          provider.portfolio_manager_email
        ]
      end
    end
  end
end
