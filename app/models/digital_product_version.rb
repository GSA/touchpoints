# frozen_string_literal: true

class DigitalProductVersion < ApplicationRecord
  belongs_to :digital_product

  validates :platform, presence: true
  validates :version_number, presence: true

  def self.import
    DigitalProductVersion.delete_all
    file = File.read("#{Rails.root}/db/seeds/json/mobile_app_versions.json")
    versions = JSON.parse(file)
    versions = versions['mobile_app_versions']

    mobile_apps = File.read("#{Rails.root}/db/seeds/json/mobile_apps.json")

    versions.each do |version|
      # look up app_version against app's Legacy ID
      touchpoints_digital_product = DigitalProduct.find_by_legacy_id(version['mobile_app_id'])

      # set digital_product_id against the app's ID
      hash = {
        legacy_id: version['id'],
        digital_product_id: touchpoints_digital_product.id,
        store_url: version['store_url'],
        platform: version['platform'],
        version_number: version['version_number'].presence || 1.0,
        publish_date: version['publish_date'],
        description: version['description'],
        whats_new: version['whats_new'],
        screenshot_url: version['screenshot'],
        device: version['device'],
        language: version['language'],
        average_rating: version['average_rating'],
        number_of_ratings: version['number_of_ratings'],
      }
      DigitalProductVersion.create!(hash)
    end
  end
end
