class Event < ApplicationRecord

  # Extend this list with all First Class event types to be logged TP-
  @@names = {
    :organization_manager_changed => 'organization_manager_changed',
    :touchpoint_archived => 'touchpoint_archived',
    :touchpoint_form_submitted => 'touchpoint_form_submitted',
    :touchpoint_published => 'touchpoint_published',
    :user_deactivated => 'user_deactivated'
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
end
