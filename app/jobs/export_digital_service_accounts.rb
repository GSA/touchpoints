# frozen_string_literal: true

class ExportDigitalServiceAccounts < ApplicationJob
  queue_as :default

  def perform(session_uuid, include_all_accounts = false, filename = "export-#{Time.zone.now}.csv")
    if include_all_accounts
      csv_content = DigitalServiceAccount.active.to_csv
    else
      csv_content = DigitalServiceAccount.to_csv
    end
    ActionCable.server.broadcast(
      "exports_channel_#{session_uuid}", { csv: csv_content, filename: }
    )
  end
end
