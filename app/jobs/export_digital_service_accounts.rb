# frozen_string_literal: true

class ExportDigitalServiceAccounts < ApplicationJob
  queue_as :default

  def perform(session_uuid, include_all_accounts: false, filename: "touchpoints-digital-service-accounts-#{Time.now.to_i}.csv")
    if include_all_accounts
      csv_content = DigitalServiceAccount.active.to_csv
    else
      csv_content = DigitalServiceAccount.to_csv
    end
    temporary_url = store_temporarily(csv_content)
    ActionCable.server.broadcast(
      "exports_channel_#{session_uuid}", { url: temporary_url, filename: }
    )
    temporary_url
  end
end
