# frozen_string_literal: true

class ExportA11V2Job < ApplicationJob
  queue_as :default

  def perform(session_uuid, form_short_uuid, start_date, end_date, filename = "export-#{Time.zone.now}.csv")
    csv_content = Form.find_by_short_uuid(form_short_uuid).to_a11_v2_csv(start_date:, end_date:)
    ActionCable.server.broadcast(
      "exports_channel_#{session_uuid}", { csv: csv_content, filename: }
    )
  end
end
