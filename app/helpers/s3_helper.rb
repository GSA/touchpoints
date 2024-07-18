# frozen_string_literal: true

module S3Helper
  def s3_client
    Aws::S3::Client.new(
      region: ENV.fetch("S3_UPLOADS_AWS_REGION"),
      credentials: Aws::Credentials.new(
        ENV.fetch("S3_UPLOADS_AWS_ACCESS_KEY_ID"),
        ENV.fetch("S3_UPLOADS_AWS_SECRET_ACCESS_KEY")
      )
    )
  end

  def s3_service
    Aws::S3::Resource.new(client: s3_client)
  end

  def s3_presigner
    Aws::S3::Presigner.new(client: s3_client)
  end

  def s3_bucket
    bucket_name = ENV.fetch('S3_UPLOADS_AWS_BUCKET_NAME')
    s3_service.bucket(bucket_name)
  end

  def s3_presigned_url(key)
    s3_presigner.presigned_url(
      :get_object,
      bucket: ENV.fetch("S3_UPLOADS_AWS_BUCKET_NAME"),
      key: key,
      expires_in: 30.minutes.to_i
    ).to_s
  end

  def store_temporarily(data, filename)
    if filename.present?
      key = "temporary_files/#{filename}"
    else
      key = "temporary_files/#{SecureRandom.uuid}"
    end

    s3_bucket.put_object({
      body: data,
      key:,
    })
    s3_presigner.presigned_url(
      :get_object,
      bucket: s3_bucket.name,
      key:,
      expires_in: 30.minutes.to_i,
    ).to_s
  end

  def timestamp_string
    Time.zone.now.strftime('%Y-%m-%d_%H-%M-%S')
  end

  # -1 to exclude headers
  def csv_record_count(csv_content)
    csv_content.lines.size - 1
  end
end
