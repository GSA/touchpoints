CarrierWave.configure do |config|
  config.fog_credentials = {
    provider:              'AWS',
    aws_access_key_id:     ENV.fetch("S3_AWS_ACCESS_KEY_ID"),
    aws_secret_access_key: ENV.fetch("S3_AWS_SECRET_ACCESS_KEY"),
    region:                ENV.fetch("S3_AWS_REGION"),
    host:                  ENV.fetch("S3_AWS_HOST")
  }
  config.fog_directory  = ENV.fetch("S3_AWS_BUCKET_NAME")
  config.fog_public = false
  config.asset_host = "https://#{ENV.fetch("S3_AWS_BUCKET_NAME")}.#{ENV.fetch("S3_AWS_HOST")}"
  config.fog_attributes = { cache_control: "public, max-age=#{30.days.to_i}" }
end
