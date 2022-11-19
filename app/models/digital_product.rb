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
    state :under_review # TODO: CLEANUP, by consolidating to "submitted"
    state :published
    state :archived

    event :submit do
      transitions from: [:created], to: :submitted
    end
    event :publish do
      transitions from: [:submitted, :under_review], to: :published
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
    file = File.read("#{Rails.root}/tmp/mobile_apps.json")
    products = JSON.parse(file)

    products.each do |product|
      hash = {
        legacy_id: product['id'],
        name: product['name'],
        short_description: product['short_description'],
        long_description: product['long_description'],
        language: product['language'],
        aasm_state: product['status'],
        tag_list: product['tag_list'],
      }
      DigitalProduct.create!(hash)
    end
  end

  def sponsoring_agencies
    Organization.where(id: organization_list)
  end
end
