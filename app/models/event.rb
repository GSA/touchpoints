require 'csv'

class Event < ApplicationRecord

  # Extend this list with all First Class event types to be logged TP-
  @@names = {
    :organization_manager_changed => 'organization_manager_changed',
    :user_deactivated => 'user_deactivated',

    :touchpoint_archived => 'touchpoint_archived',
    :touchpoint_form_submitted => 'touchpoint_form_submitted',
    :touchpoint_published => 'touchpoint_published',

    :form_archived => 'form_archived',
    :form_submitted => 'form_submitted',
    :form_published => 'form_published',
    :form_copied => 'form_copied',
    :form_deleted => 'form_deleted',

    :response_deleted => 'response_deleted'
  }

  def self.log_event(ename, otype, oid, desc, uid = nil)
    e = self.new
    e.name = ename
    e.object_type = otype
    e.object_id = oid
    e.description = desc
    e.user_id = uid
    e.save
  end

  def self.names
    @@names
  end

  def self.valid_events
    @@names.values
  end

  def self.to_csv
    attributes = [
      :name,
      :object_type,
      :object_id,
      :description,
      :user_id,
      :created_at,
      :updated_at
    ]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      Event.all.each do |event|
        csv << attributes.map { |attr| event.send(attr) }
      end
    end
  end
end
