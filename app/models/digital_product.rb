# frozen_string_literal: true

require 'json'
require 'open-uri'

class DigitalProduct < ApplicationRecord
  include AASM
  has_paper_trail
  resourcify
  acts_as_taggable_on :tags, :organizations
  
  has_many :digital_product_versions

  validates :name, presence: true

  scope :active, -> { where(aasm_state: :published) }

  aasm do
    state :created, initial: true
    state :submitted
    state :published
    state :archived

    event :submit do
      transitions from: [:created], to: :submitted
    end
    event :publish do
      transitions from: [:submitted], to: :published
    end
    event :archive do
      transitions to: :archived
    end
    event :reset do
      transitions to: :created
    end
  end

  def self.import
    DigitalProduct.delete_all
    file = File.read("#{Rails.root}/db/seeds/json/mobile_apps.json")
    products = JSON.parse(file)
    products = products['mobile_apps']
    products.each do |product|
      hash = {
        id: product['id'],
        name: product['name'],
        short_description: product['short_description'],
        long_description: product['long_description'],
        language: product['language'],
      }
      DigitalProduct.create!(hash)
    end
  end

  def self.load_digital_products
    DigitalProduct.delete_all

    url = 'https://usdigitalregistry.digitalgov.gov/digital-registry/v1/mobile_apps?page_size=10000'

    response = URI.open(url).read
    json = JSON.parse(response)

    products = json['results']
    Rails.logger.debug { "Found #{products.size} Products" }

    products.each do |product|
      hash = {
        name: product['name'],
        short_description: product['short_description'],
        long_description: product['long_description'],
        language: product['language'],

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

    Rails.logger.debug 'Loaded DigitalServiceAccounts'
  end

  def sponsoring_agencies
    Organization.where(id: organization_list)
  end
end
