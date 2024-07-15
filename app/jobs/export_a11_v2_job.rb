# frozen_string_literal: true

class ExportA11V2Job < ApplicationJob
  queue_as :default

  def perform(email:, form_uuid:, filename:)
    start_date = Time.now
    csv_content = Form.find_by_short_uuid(form_short_uuid).to_a11_v2_csv(start_date:, end_date:)
    temporary_url = store_temporarily(csv_content)
    completion_date = Time.now
    record_count = csv_content.size
    UserMailer.async_report_notification(email:, start_date:, completion_date:, record_count:, url: temporary_url)
  end
end
