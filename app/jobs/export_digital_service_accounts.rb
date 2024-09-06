# frozen_string_literal: true

class ExportDigitalServiceAccounts < ApplicationJob
  queue_as :default

    start_time = Time.now
  def perform(user:, query:, org_abbr:, aasm_state:, account:)
    query = DigitalServiceAccount
      .filtered_accounts(query, org_abbr, aasm_state, account)
    csv_content = query.to_csv
    completion_time = Time.now
    record_count = csv_record_count(csv_content)

    filename = "touchpoints-digital-service-accounts-#{timestamp_string}.csv"
    url = store_temporarily(csv_content, filename)
    UserMailer.async_report_notification(email:, start_time:, completion_time:, record_count:, url:).deliver_later
  end
end
