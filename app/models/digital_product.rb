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
    state :updated
    state :submitted
    state :under_review # TODO: CLEANUP, by consolidating to "submitted"
    state :published
    state :archived

    event :submit do
      transitions from: [:created, :updated], to: :submitted
    end
    event :publish do
      transitions from: [:submitted, :under_review], to: :published
    end
    event :archive do
      transitions to: :archived
    end
    event :update_state do
      transitions to: :updated
    end
    event :reset do
      transitions to: :created
    end
  end

  def sponsoring_agencies
    Organization.where(id: organization_list)
  end

  def contacts
    User.with_role(:contact, self)
  end

  def contact_emails
    contacts.collect(&:email).join(", ")
  end

  def organization_names
    Organization.find(self.organization_list).collect(&:name).join(", ")
  end

  def self.to_csv
    attributes = DigitalProduct.first.attributes.keys

    digital_products = DigitalProduct.all

    attributes = [
      :id,
      :name,
      :contact_emails,
      :organization_names,
      :url,
      :code_repository_url,
      :language,
      :tag_list,
      :service,
      :short_description,
      :long_description,
      :notes,
      :certified_at,
      :created_at,
      :updated_at,
      :aasm_state,
      :legacy_id,
      :legacy_notes,
    ]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      digital_products.each do |digital_service_account|
        csv << attributes.map { |attr| digital_service_account.send(attr) }
      end
    end
  end
end
