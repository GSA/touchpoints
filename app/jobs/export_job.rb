# frozen_string_literal: true

class ExportJob < ApplicationJob
  queue_as :default

  def perform(email, form_short_uuid, start_date, end_date, filename = "export-#{Time.zone.now}.csv")
    form = Form.find_by_short_uuid(form_short_uuid)
    record_count = form.response_count

    start_time = Time.now
    csv_content = form.to_csv(start_date:, end_date:)
    temporary_url = store_temporarily(csv_content)
    completion_time = Time.now

    UserMailer.async_report_notification(email:, start_time:, completion_time:, record_count:, url: temporary_url).deliver_later
  end
end
