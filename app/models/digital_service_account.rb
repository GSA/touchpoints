# frozen_string_literal: true

require 'json'
require 'open-uri'
require 'csv'

class DigitalServiceAccount < ApplicationRecord
  include AASM
  has_paper_trail
  resourcify
  acts_as_taggable_on :tags, :organizations

  belongs_to :organization, optional: true

  validates :name, presence: true
  validates :name, uniqueness: { scope: :service }
  validates :service, presence: true
  validate :validate_service_types
  validates :service_url, presence: true
  validates :service_url, uniqueness: true

  scope :active, -> { where(aasm_state: :published) }

  scope :filtered_accounts, lambda { |query, organization_abbreviation, aasm_state, service|
    @organization = Organization.find_by_abbreviation(organization_abbreviation)

    wildcard_query = "%#{query}%"

    items = all
    items = items.tagged_with(@organization.id, context: 'organizations') if @organization.present?
    items = items.where(aasm_state:) if aasm_state.present? && aasm_state.downcase != 'all'
    items = items.where(service: service) if service.present? && service.downcase != 'all'
    items = items.where("name ILIKE ? OR service ILIKE ? OR short_description ILIKE ? OR service_url ILIKE ?", wildcard_query, wildcard_query, wildcard_query, wildcard_query) if query && query.length >= 3

    items
  }

  aasm do
    state :created, initial: true
    state :submitted
    state :published
    state :updated
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

  def sponsoring_agencies
    Organization.where(id: organization_list)
  end

  def contacts
    User.with_role(:contact, self)
  end

  def self.list
    [
      'disqus',
      'eventbrite',
      'facebook',
      'flickr',
      'foursquare',
      'giphy',
      'github',
      'google plus',
      'ideascale',
      'instagram',
      'linkedin',
      'linktree',
      'livestream',
      'mastodon',
      'medium',
      'myspace',
      'pinterest',
      'reddit',
      'scribd',
      'slideshare',
      'socrata',
      'storify',
      'tableau',
      'threads',
      'tumblr',
      'twitter',
      'uservoice',
      'ustream',
      'vimeo',
      'yelp',
      'youtube',
      'other',
    ]
  end

  def validate_service_types
    errors.add(:service, "Invalid service platform '#{service}'") unless DigitalServiceAccount.list.include?(service)
  end

  def contact_emails
    contacts.collect(&:email).join(', ')
  end

  def organization_names
    Organization.find(organization_list).collect(&:name).join(', ')
  end

  def self.to_csv
    header_attributes = DigitalServiceAccount.first.attributes.keys

    digital_service_accounts = DigitalServiceAccount.all

    attributes = [
      :id,
      :name,
      :contact_emails,
      :organization_names,
      :tag_list,
      :service,
      :service_url,
      :language,
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

      digital_service_accounts.each do |digital_service_account|
        csv << attributes.map { |attr| digital_service_account.send(attr) }
      end
    end
  end

  def self.list2
    {
      'Disqus' => "https://disqus.com/",
      'Eventbrite' => '',
      'Facebook' => '',
      'Flickr' => '',
      'Foursquare' => '',
      'Giphy' => '',
      'Github' => '',
      'Google plus' => '',
      'Ideascale' => '',
      'Instagram' => '',
      'Linkedin' => '',
      'Livestream' => '',
      'Mastodon' => '',
      'Medium' => '',
      'Myspace' => '',
      'Pinterest' => '',
      'Reddit' => '',
      'Scribd' => '',
      'Slideshare' => '',
      'Socrata' => '',
      'Storify' => '',
      'Tumblr' => '',
      'Twitter' => '',
      'Uservoice' => '',
      'Ustream' => '',
      'Vimeo' => '',
      'Yelp' => '',
      'Youtube' => '',
      'Other' => nil,
    }
  end
end
