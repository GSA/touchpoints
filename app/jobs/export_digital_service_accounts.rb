# frozen_string_literal: true

class ExportDigitalServiceAccounts < ApplicationJob
  queue_as :default

  def perform(email:, query:, org_abbr:, aasm_state:, account:)
    start_time = Time.now
    accounts = DigitalServiceAccount
      .filtered_accounts(query, org_abbr, aasm_state, account)
    csv_content = accounts.to_csv
    completion_time = Time.now
    record_count = csv_record_count(csv_content)

    filename = "touchpoints-digital-service-accounts-#{timestamp_string}.csv"
    url = store_temporarily(csv_content, filename)
    UserMailer.async_report_notification(email:, start_time:, completion_time:, record_count:, url:).deliver_later
  end
end
