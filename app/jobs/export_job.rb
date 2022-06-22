# frozen_string_literal: true

class ExportJob < ApplicationJob
  queue_as :default

  def perform(session_uuid, form_short_uuid, start_date, end_date, filename = "export-#{Time.zone.now}.csv")
    csv_content = Form.find_by_short_uuid(form_short_uuid).to_csv(start_date:, end_date:)
    ActionCable.server.broadcast(
      "exports_channel_#{session_uuid}", { csv: csv_content, filename: }
    )
  end
end
