# frozen_string_literal: true

class Organization < ApplicationRecord
  MAX_DOMAIN_PARTS = 5

  acts_as_taggable_on :tags

  has_many :users
  has_many :service_providers
  has_many :services
  has_many :websites
  has_many :cx_collections
  has_many :forms

  mount_uploader :logo, LogoUploader

  validates :name, presence: true
  validates :name, uniqueness: true
  validates :domain, presence: true, uniqueness: true
  validates :domain, format: {
    with: /\A[a-z0-9]+([\-\.][a-z0-9]+)*\.[a-z]{2,}\z/i,
    message: "must be a bare domain name (e.g., 'example.gov') without protocol, path, or trailing slash"
  }, allow_blank: true
  validate :domain_parts_limit
  validates :abbreviation,
    presence: true,
    uniqueness: true,
    length: { maximum: 10 },
    format: { with: /\A[a-zA-Z0-9]*\z/, message: "only allows letters and numbers" }

  def domain_parts_limit
    return if domain.blank?
    
    parts = domain.split('.')
    if parts.size > MAX_DOMAIN_PARTS
      errors.add(:domain, "cannot have more than 5 parts (e.g., 'sub1.sub2.sub3.example.gov')")
    end
  end

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

  def organizational_form_approvers
    users.where(organizational_form_approver: true)
  end
end
