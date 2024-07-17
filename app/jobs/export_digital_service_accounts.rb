# frozen_string_literal: true

class ExportDigitalServiceAccounts < ApplicationJob
  queue_as :default

  def perform(email:, include_all_accounts: false)
    start_time = Time.now
    if include_all_accounts
      query = DigitalServiceAccount.all
    else
      query = DigitalServiceAccount.active
    end
    csv_content = query.to_csv
    completion_time = Time.now
    record_count = query.count

    filename = "touchpoints-digital-service-accounts-#{timestamp_string}.csv"
    url = store_temporarily(csv_content, filename)
    UserMailer.async_report_notification(email:, start_time:, completion_time:, record_count:, url:).deliver_later
  end
end
