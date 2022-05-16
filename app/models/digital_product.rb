require 'json'
require 'open-uri'

class DigitalProduct < ApplicationRecord
  belongs_to :user
  belongs_to :organization
  has_many :digital_product_versions

  def self.load_digital_products
    DigitalProduct.delete_all

    url = "https://usdigitalregistry.digitalgov.gov/digital-registry/v1/mobile_apps?page_size=10000"

    response = URI.open(url).read
    json = JSON.parse(response)

    products = json["results"]
    puts "Found #{products.size} Products"

    products.each do |product|
      hash = {
        name: product["name"],
        short_description: product["short_description"],
        long_description: product["long_description"],
        language: product["language"],

        organization: Organization.first,
        user: User.first,

        # TODO:
        # agencies = []
        # tags = []
        # versions = []
          # {
          #   "store_url": "http://itunes.apple.com/us/app/...,
          #   "platform": "iOS",
          #   "version_number": "",
          #   "publish_date": "2012-10-04T00:00:00.000Z",
          #   "screenshot": "",
          #   "device": "App - Phone/Tablet",
          #   "average_rating": "4.5",
          #   "number_of_ratings": 21
          # }
        # icon_url
      }
      DigitalProduct.create!(hash)
    end

    puts "Loaded DigitalServiceAccounts"
  end
end
