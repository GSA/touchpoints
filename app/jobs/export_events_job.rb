# frozen_string_literal: true

class ExportEventsJob < ApplicationJob
  queue_as :default

  def perform(email:)
    filename = "touchpoints-system-events-#{Time.zone.now}.csv"
    start_time = Time.now
    csv_content = Event.to_csv
    temporary_url = store_temporarily(csv_content)
    completion_time = Time.now
    record_count = csv_content.size
    UserMailer.async_report_notification(email:, start_time:, completion_time:, record_count:, url: temporary_url).deliver_later
  end
end
