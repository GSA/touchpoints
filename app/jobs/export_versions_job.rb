# frozen_string_literal: true

class ExportVersionsJob < ApplicationJob
  queue_as :default

  def perform(email, versionable, filename)
    start_time = Time.now
    csv_content = Version.to_csv(versionable)
    temporary_url = store_temporarily(csv_content, filename)
    completion_time = Time.now
    record_count = csv_record_count(csv_content)
    UserMailer.async_report_notification(email:, start_time:, completion_time:, record_count:, url: temporary_url).deliver_later
  end
end
