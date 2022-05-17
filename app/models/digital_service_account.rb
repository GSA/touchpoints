require 'json'
require 'open-uri'

class DigitalServiceAccount < ApplicationRecord
  belongs_to :organization
  belongs_to :user

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
