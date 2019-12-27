class ExportJob < ApplicationJob
  queue_as :default

  def perform(uuid,touchpoint_id,filename = "export.csv")
    # Do something later

    sleep 10
    csv_content = Touchpoint.find(touchpoint_id).to_csv
    ActionCable.server.broadcast(
      "exports_channel_#{uuid}", csv: csv_content, filename: filename
    )
  end
end
