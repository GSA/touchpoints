class ExportJob < ApplicationJob
  queue_as :default

  def perform(uuid,touchpoint_short_uuid,filename = "export.csv")
    csv_content = Touchpoint.find_by_short_uuid(touchpoint_short_uuid).to_csv
    ActionCable.server.broadcast(
      "exports_channel_#{uuid}", csv: csv_content, filename: filename
    )
  end
end
