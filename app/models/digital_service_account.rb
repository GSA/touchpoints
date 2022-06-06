require 'json'
require 'open-uri'

class DigitalServiceAccount < ApplicationRecord
  include AASM
  acts_as_taggable_on :tags

  has_paper_trail
  resourcify

  aasm do
    state :created, initial: true
    state :certified
    state :published
    state :archived

    event :certify do
      transitions from: [:created], to: :certified
    end
    event :publish do
      transitions from: [:certified], to: :published
    end
    event :archive do
      transitions from: [:created, :published], to: :archived
    end
    event :reset do
      transitions to: :created
    end
  end

  def organization_name
    self.organization.name
  end

  def organization_abbreviation
    self.organization.abbreviation
  end

  def self.load_service_accounts
    DigitalServiceAccount.delete_all

    url = "https://usdigitalregistry.digitalgov.gov/digital-registry/v1/social_media?page_size=10000"

    response = URI.open(url).read
    json = JSON.parse(response)

    accounts = json["results"]
    puts "Found #{accounts.size} Accounts"

    accounts.each do |account|
      hash = {

        name: account["service_display_name"],
        short_description: account["short_description"],
        long_description: account["long_description"],
        service_url: account["service_url"],
        language: account["language"],
        account: account["account"],
        service: account["service_key"],

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

    puts "Loaded DigitalServiceAccount"
  end
end
