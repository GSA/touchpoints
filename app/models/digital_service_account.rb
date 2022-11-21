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

end
