# frozen_string_literal: true

class ExportJob < ApplicationJob
  queue_as :default

  def perform(email, form_short_uuid, start_date, end_date)

    form = Form.find_by_short_uuid(form_short_uuid)

    start_time = Time.now
    csv_content = form.to_csv(start_date:, end_date:)
    record_count = csv_record_count(csv_content)
    filename = "touchpoints-form-#{form.short_uuid}-#{form.name.parameterize}-responses-#{timestamp_string}.csv"
    temporary_url = store_temporarily(csv_content, filename)
    completion_time = Time.now

    UserMailer.async_report_notification(email:, start_time:, completion_time:, record_count:, url: temporary_url).deliver_later
  end
end
