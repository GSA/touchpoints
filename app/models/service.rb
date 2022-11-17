# frozen_string_literal: true

require 'csv'

class Service < ApplicationRecord
  resourcify
  include AASM
  has_paper_trail

  belongs_to :organization
  belongs_to :service_provider, optional: true, counter_cache: true
  has_many :service_stages, dependent: :delete_all
  has_many :omb_cx_reporting_collections
  has_many :collections, through: :omb_cx_reporting_collections
  has_many :forms

  acts_as_taggable_on :tags, :channels

  validates :name, presence: true
  validates :service_owner_id, presence: true
  validates :non_digital_explanation, length: { maximum: 250 }

  scope :hisp, -> { where(hisp: true) }

  after_create :create_default_service_stages
  after_create :create_roles

  aasm do
    state :created, initial: true
    state :submitted
    state :approved
    state :verified
    state :archived

    event :submit do
      transitions from: [:created], to: :submitted
    end
    event :approve do
      transitions from: [:submitted], to: :approved
    end
    event :verify do
      transitions from: [:approved], to: :verified
    end
    event :archive do
      transitions from: [:verified], to: :archived
    end
    event :reset do
      transitions to: :created
    end
  end

  def create_default_service_stages
    service_stages.create(position: 10, name: :start)
    service_stages.create(position: 20, name: :process)
    service_stages.create(position: 100, name: :end)
  end

  def create_roles
    service_owner.add_role :service_manager, self
  end

  def owner?(user:)
    return false unless user

    user.admin? || service_owner_id == user.id
  end

  def service_owner
    return nil unless service_owner_id

    User.find_by_id(service_owner_id)
  end

  def service_managers
    User.with_role(:service_manager, self)
  end

  def service_owner_email
    service_owner&.try(:email)
  end

  delegate :name, to: :organization, prefix: true

  delegate :abbreviation, to: :organization, prefix: true

  def service_provider_name
    service_provider ? service_provider.name : nil
  end

  #
  # Channels
  # How a service is delivered to an end-user.
  #
  def self.channels
    %i[
      computer
      mobile
      email
      chatbot
      phone
      automated_phone
      in_person
      paper

      postal_mail
      fax
      self_service_kiosk
      other_non_digital
      website
      mobile_app
      live_chat
      sms_text_messages
      social_media
      other_digital
    ]
  end

  def self.kinds
    [
      'Administrative',
      'Benefits',
      'Compliance',
      'Recreation',
      'Informational',
      'Data and Research',
      'Regulatory',
      'Other',
    ]
  end

  def available_in_person?
    channel_list.include?('in_person') ||
      channel_list.include?('paper')
  end

  def available_digitally?
    channel_list.include?('computer') ||
      channel_list.include?('mobile') ||
      channel_list.include?('email') ||
      channel_list.include?('chatbot')
  end

  def available_via_phone?
    channel_list.include?('phone') ||
      channel_list.include?('automated_phone')
  end

  def self.to_csv
    services = Service.order('organizations.name').includes(:organization)

    example_service_attributes = Service.new.attributes
    attributes = example_service_attributes.keys

    CSV.generate(headers: true) do |csv|
      csv << attributes

      services.each do |service|
        csv << attributes.map { |attr| service.send(attr) }
      end
    end
  end
end
