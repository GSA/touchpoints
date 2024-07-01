# frozen_string_literal: true

class Organization < ApplicationRecord
  acts_as_taggable_on :tags

  has_many :users
  has_many :service_providers
  has_many :services
  has_many :websites
  has_many :collections
  has_many :cx_collections
  has_many :cscrm_data_collections
  has_many :cscrm_data_collections2, class_name: "CscrmDataCollection2"
  has_many :goals
  has_many :milestones, through: :goals
  has_many :objectives, through: :milestones
  has_many :forms

  mount_uploader :logo, LogoUploader

  validates :name, presence: true
  validates :name, uniqueness: true
  validates :domain, presence: true
  validates :abbreviation, presence: true
  validates :abbreviation, uniqueness: true

  def parent
    parent_id ? Organization.find(parent_id) : nil
  end

  def children
    Organization.where(parent_id: self.id)
  end

  def slug
    abbreviation.downcase
  end

  def to_param
    slug
  end

  def has_form_approval_enabled?
    true if abbreviation == "OMB"
  end
end
