# frozen_string_literal: true

class ExportVersionsJob < ApplicationJob
  queue_as :default

  def perform(session_uuid, versionable, filename = "touchpoints-versions-#{Time.zone.now}.csv")
    csv_content = Version.to_csv(versionable)
    temporary_url = store_temporarily(csv_content)
    ActionCable.server.broadcast(
      "exports_channel_#{session_uuid}", { url: temporary_url, filename: }
    )
  end
end
