# frozen_string_literal: true

class ExportDigitalServiceAccounts < ApplicationJob
  include S3Helper

  queue_as :default

  def perform(email:, include_all_accounts: false)
    start_time = Time.now
    if include_all_accounts
      csv_content = DigitalServiceAccount.active.to_csv
    else
      csv_content = DigitalServiceAccount.to_csv
    end
    completion_time = Time.now
    record_count = csv_content.size

    filename = "touchpoints-digital-service-accounts-#{timestamp_string}.csv"
    url = store_temporarily(csv_content, filename)
    UserMailer.async_report_notification(email:, start_time:, completion_time:, record_count:, url:).deliver_later
  end
end
