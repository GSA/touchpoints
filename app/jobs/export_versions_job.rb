class ExportVersionsJob < ApplicationJob
  queue_as :default

  def perform(session_uuid, versionable, filename = "touchpoints-versions-#{Time.now.to_s}.csv")
    csv_content = Version.to_csv(versionable)
    ActionCable.server.broadcast(
      "exports_channel_#{session_uuid}", { csv: csv_content, filename: filename }
    )
  end
end
