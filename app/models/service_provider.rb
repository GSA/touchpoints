# frozen_string_literal: true

class ServiceProvider < ApplicationRecord
  resourcify
  belongs_to :organization
  has_many :services
  has_many :cx_collections, through: :services
  has_many :cx_collection_details, through: :cx_collections
  acts_as_taggable_on :tags

  validates :name, presence: true
  validates :slug, presence: true

  scope :active, -> { where('inactive = false') }

  def service_provider_managers
    User.with_role(:service_provider_manager, self)
  end

  delegate :name, to: :organization, prefix: true

  delegate :abbreviation, to: :organization, prefix: true

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << %i[
        id
        organization_id
        organization_name
        organization_abbreviation
        service_provider_slug
        name
        description
        year_designated
        notes
        new_hisp
        inactive
        url
        services_count
        portfolio_manager_email
        service_provider_managers
      ]

      ServiceProvider
        .includes(:organization)
        .order('organizations.name', :name).each do |provider|
        csv << [
          provider.id,
          provider.organization_id,
          provider.organization.name,
          provider.organization.abbreviation.downcase,
          provider.slug,
          provider.name,
          provider.description,
          provider.year_designated,
          provider.notes,
          provider.new,
          provider.inactive,
          provider.url,
          provider.services_count,
          provider.portfolio_manager_email,
          provider.service_provider_managers.collect(&:email),
        ]
      end
    end
  end
end
