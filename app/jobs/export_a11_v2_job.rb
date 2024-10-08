# frozen_string_literal: true

class ExportA11V2Job < ApplicationJob
  queue_as :default

  def perform(email:, form_uuid:, start_date:, end_date:)
    start_time = Time.now
    csv_content = Form
      .find_by_short_uuid(form_uuid)
      .to_a11_v2_csv(start_date:, end_date:)
    filename = "touchpoints-a11-v2-form-responses-#{timestamp_string}.csv"
    temporary_url = store_temporarily(csv_content, filename)
    completion_time = Time.now
    record_count = csv_record_count(csv_content)
    UserMailer.async_report_notification(email:, start_time:, completion_time:, record_count:, url: temporary_url).deliver_later
  end
end
