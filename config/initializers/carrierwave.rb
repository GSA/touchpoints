# frozen_string_literal: true

require_relative 'vcap_services'

CarrierWave.configure do |config|
  if Rails.env.development? || Rails.env.test?
    config.storage = :file
  else
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: ENV.fetch('S3_AWS_ACCESS_KEY_ID'),
      aws_secret_access_key: ENV.fetch('S3_AWS_SECRET_ACCESS_KEY'),
      region: ENV.fetch('S3_AWS_REGION'),
    }
    config.fog_directory = ENV.fetch('S3_AWS_BUCKET_NAME')
    config.fog_public = false
    config.asset_host = "https://#{ENV.fetch('S3_AWS_BUCKET_NAME')}.s3-#{ENV.fetch('S3_AWS_REGION')}.amazonaws.com"
    config.fog_attributes = { cache_control: "public, max-age=#{30.days.to_i}" }
  end
end
