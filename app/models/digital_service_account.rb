# frozen_string_literal: true

require 'json'
require 'open-uri'

class DigitalServiceAccount < ApplicationRecord
  include AASM
  has_paper_trail
  resourcify
  acts_as_taggable_on :tags, :organizations

  belongs_to :organization, optional: true

  validates :name, uniqueness: { scope: :account }

  # validates :name, presence: true

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

  def sponsoring_agencies
    Organization.where(id: organization_list)
  end

  def contacts
    User.with_role(:contact, self)
  end

  def self.list
    [
      'Disqus',
      'Eventbrite',
      'Facebook',
      'Flickr',
      'Foursquare',
      'Giphy',
      'Github',
      'Google plus',
      'Ideascale',
      'Instagram',
      'Linkedin',
      'Livestream',
      'Mastodon',
      'Medium',
      'Myspace',
      'Pinterest',
      'Reddit',
      'Scribd',
      'Slideshare',
      'Socrata',
      'Storify',
      'Tumblr',
      'Twitter',
      'Uservoice',
      'Ustream',
      'Vimeo',
      'Yelp',
      'Youtube',
      'Other'
    ]
  end

  def user_email
    return nil unless self.user_id
    if user
      return user.email
    end
  end

  def contact_emails
    contacts.collect(&:email).join(", ")
  end

  def organization_names
    Organization.find(self.organization_list).collect(&:name).join(", ")
  end

  def self.to_csv
    header_attributes = DigitalServiceAccount.first.attributes.keys

    digital_service_accounts = DigitalServiceAccount.all

    attributes = [
      :id,
      :account,
      :name,
      :user_email,
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
      'Other' => nil
    }
  end

end
