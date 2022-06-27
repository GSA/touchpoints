# frozen_string_literal: true

class DigitalProductVersion < ApplicationRecord
  belongs_to :digital_product

  validates :platform, presence: true
  validates :version_number, presence: true

  def self.import
    DigitalProductVersion.delete_all
    file = File.read("#{Rails.root}/db/seeds/json/mobile_app_versions.json")
    versions = JSON.parse(file)
    versions = versions["mobile_app_versions"]
    versions.each do |version|
      hash = {
        id: version['id'],
        digital_product_id: version['mobile_app_id'],
        store_url: version['store_url'],
        platform: version['platform'],
        version_number: version['version_number'].present? ? version['version_number'] : 1.0,
        publish_date: version['publish_date'],
        description: version['description'],
        whats_new: version['whats_new'],
        screenshot_url: version['screenshot'],
        device: version['device'],
        language: version['languag'],
        average_rating: version['average_rating'],
        number_of_ratings: version['number_of_ratings'],
      }
      DigitalProductVersion.create!(hash)
    end
  end
end


