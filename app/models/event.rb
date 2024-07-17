# frozen_string_literal: true

require 'csv'

class Event < ApplicationRecord
  # Event::Generic is used to log generic types of events, such as sign in attempts
  class Generic
    # `1` is used as an id for Generic events
  end

  belongs_to :user, optional: true

  # Extend this list with all First Class event types to be logged TP-
  @@names = {
    organization_manager_changed: 'organization_manager_changed', # Legacy event
    user_deactivated: 'user_deactivated',
    user_reactivated: 'user_reactivated',
    user_deleted: 'user_deleted',
    user_update: 'user_update',
    user_authentication_attempt: 'user_authentication_attempt',
    user_authentication_successful: 'user_authentication_successful',
    user_authentication_failure: 'user_authentication_failure',
    user_send_invitation: 'user_send_invitation',

    touchpoint_form_submitted: 'touchpoint_form_submitted',

    form_created: 'form_created',
    form_submitted: 'form_submitted',
    form_approved: 'form_approved',
    form_published: 'form_published',
    form_archived: 'form_archived',
    form_copied: 'form_copied',
    form_deleted: 'form_deleted',
    form_reset: 'form_reset',

    collection_created: 'collection_created',
    collection_updated: 'collection_updated',
    collection_copied: 'collection_copied',
    collection_submitted: 'collection_submitted',
    collection_published: 'collection_published',
    collection_change_requested: 'collection_change_requested',
    collection_deleted: 'collection_deleted',

    collection_cx_created: 'collection_cx_created',
    collection_cx_updated: 'collection_cx_updated',
    collection_cx_copied: 'collection_cx_copied',
    collection_cx_submitted: 'collection_cx_submitted',
    collection_cx_published: 'collection_cx_published',
    collection_cx_change_requested: 'collection_cx_change_requested',
    collection_cx_deleted: 'collection_cx_deleted',

    cx_collection_created: 'cx_collection_created',
    cx_collection_updated: 'cx_collection_updated',
    cx_collection_copied: 'cx_collection_copied',
    cx_collection_submitted: 'cx_collection_submitted',
    cx_collection_published: 'cx_collection_published',
    cx_collection_reset: 'cx_collection_reset',
    cx_collection_not_reported: 'cx_collection_not_reported',
    cx_collection_change_requested: 'cx_collection_change_requested',
    cx_collection_deleted: 'cx_collection_deleted',

    cscrm_data_collection_collection_created: 'cscrm_data_collection_collection_created',
    cscrm_data_collection_collection_updated: 'cscrm_data_collection_collection_updated',
    cscrm_data_collection_collection_submitted: 'cscrm_data_collection_collection_submitted',
    cscrm_data_collection_collection_published: 'cscrm_data_collection_collection_published',
    cscrm_data_collection_collection_reset: 'cscrm_data_collection_collection_reset',
    cscrm_data_collection_collection_deleted: 'cscrm_data_collection_collection_deleted',

    response_flagged: 'response_flagged',
    response_unflagged: 'response_unflagged',
    response_archived: 'response_archived',
    response_unarchived: 'response_unarchived',
    response_deleted: 'response_deleted',
    response_status_changed: 'response_status_changed',

    website_created: 'website_created',
    website_submitted: 'website_submitted',
    website_published: 'website_published',

    website_staged: 'website_staged',
    website_launched: 'website_launched',
    website_redirected: 'website_redirected',
    website_archived: 'website_archived',
    website_decommissioned: 'website_decommissioned',
    website_reset: 'website_reset',
    website_deleted: 'website_deleted',
    website_updated: 'website_updated',
    website_state_changed: 'website_state_changed',

    digital_product_created: 'digital_product_created',
    digital_product_updated: 'digital_product_updated',
    digital_product_submitted: 'digital_product_submitted',
    digital_product_published: 'digital_product_published',
    digital_product_archived: 'digital_product_archived',
    digital_product_reset: 'digital_product_reset',
    digital_product_deleted: 'digital_product_deleted',

    digital_service_account_created: 'digital_service_account_created',
    digital_service_account_updated: 'digital_service_account_updated',
    digital_service_account_submitted: 'digital_service_account_submitted',
    digital_service_account_published: 'digital_service_account_published',
    digital_service_account_archived: 'digital_service_account_archived',
    digital_service_account_reset: 'digital_service_account_reset',
    digital_service_account_deleted: 'digital_service_account_deleted',

    organization_created: 'organization_created',
    organization_updated: 'organization_updated',
    organization_deleted: 'organization_deleted',
  }

  def self.log_event(ename, otype, oid, desc, uid = nil)
    e = new
    e.name = ename
    e.object_type = otype
    e.object_uuid = oid
    e.description = desc
    e.user_id = uid
    e.save
    e
  end

  def self.names
    @@names
  end

  def self.valid_events
    @@names.values
  end

  def self.to_csv
    attributes = %i[
      name
      object_type
      object_uuid
      description
      user_id
      created_at
      updated_at
    ]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      Event.all.find_each do |event|
        csv << attributes.map { |attr| event.send(attr) }
      end
    end
  end
end
