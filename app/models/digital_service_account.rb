# frozen_string_literal: true

require 'json'
require 'open-uri'

class DigitalServiceAccount < ApplicationRecord
  include AASM
  acts_as_taggable_on :tags, :organizations

  has_paper_trail

  resourcify

  scope :active, -> { where(aasm_state: :published) }

  aasm do
    state :created, initial: true
    state :updated
    state :submitted
    state :published
    state :archived

    event :submit do
      transitions from: %i[created updated], to: :submitted
    end
    event :publish do
      transitions from: [:submitted], to: :published
    end
    event :archive do
      transitions to: :archived
    end
    event :update_state do
      transitions to: :updated
    end
    event :reset do
      transitions to: :updated
    end
  end

  delegate :name, to: :organization, prefix: true

  delegate :abbreviation, to: :organization, prefix: true

  def sponsoring_agencies
    Organization.where(id: organization_list)
  end

  def contacts
    User.with_role(:contact, self)
  end

  def self.load_service_accounts
    DigitalServiceAccount.delete_all

    url = 'https://usdigitalregistry.digitalgov.gov/digital-registry/v1/social_media?page_size=10000'

    response = URI.open(url).read
    json = JSON.parse(response)

    accounts = json['results']
    Rails.logger.debug { "Found #{accounts.size} Accounts" }

    accounts.each do |account|
      hash = {

        name: account['service_display_name'],
        short_description: account['short_description'],
        long_description: account['long_description'],
        service_url: account['service_url'],
        language: account['language'],
        account: account['account'],
        service: account['service_key'],

        organization: Organization.first,
        user: User.first,

        # TODO:
        # tags = []
        # agencies = []
        # legacy_id
        # organization
        # service_display_name
      }
      DigitalServiceAccount.create!(hash)
    end

    Rails.logger.debug 'Loaded DigitalServiceAccount'
  end
end
