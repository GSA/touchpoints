class ExportWebsiteVersionsJob < ApplicationJob
  queue_as :default

  def perform(session_uuid, website_id, filename = "touchpoints-website-versions.csv")
    website = Website.find(website_id)
    csv_content = Version.to_csv(website)
    ActionCable.server.broadcast(
      "exports_channel_#{session_uuid}", csv: csv_content, filename: filename
    )
  end
end
