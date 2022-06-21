# frozen_string_literal: true

class ExportEventsJob < ApplicationJob
  queue_as :default

  def perform(session_uuid, filename = "touchpoints-system-events-#{Time.zone.now}.csv")
    csv_content = Event.to_csv
    ActionCable.server.broadcast(
      "exports_channel_#{session_uuid}", { csv: csv_content, filename: }
    )
  end
end
