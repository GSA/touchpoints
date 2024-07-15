# frozen_string_literal: true

class ExportDigitalServiceAccounts < ApplicationJob
  include ApplicationHelper

  queue_as :default

  def perform(email:, include_all_accounts: false, filename: "touchpoints-digital-service-accounts-#{Time.now.to_i}.csv")
    start_time = Time.now
    if include_all_accounts
      csv_content = DigitalServiceAccount.active.to_csv
    else
      csv_content = DigitalServiceAccount.to_csv
    end
    completion_time = Time.now
    record_count = csv_content.size

    url = write_to_private_s3(filename: filename, content: csv_content)
    UserMailer.async_report_notification(email:, start_time:, completion_time:, record_count:, url:).deliver_later
  end


  private

  def write_to_private_s3(filename:, content:)
    bucket = ENV.fetch("S3_UPLOADS_AWS_BUCKET_NAME")
    key = "reports/#{filename}"

    obj = s3_service.bucket(bucket).object(key)
    response = obj.put(body: content)
    s3_presigned_url(key)
  end
end
