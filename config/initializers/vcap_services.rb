# frozen_string_literal: true

# Try to get S3 settings from Cloud Foundry's VCAP_SERVICES object
vcap_services = ENV.fetch('VCAP_SERVICES', nil)

#
# Define helper methods
#
def set_s3!(vcap_services_json)
  s3_settings = vcap_services_json['s3']
  return false if s3_settings.blank?

  s3_credentials = s3_settings[0]['credentials']
  raise StandardError, 's3 credentials could not be derived from Cloud Foundry VCAP_SERVICES' if s3_credentials.blank?

  # Set ENV variables based on Cloud Foundry's VCAP_SERVICES object
  # Note: this is done this way to allow Touchpoints to use ENV variables
  # on other platforms as well.
  ENV['S3_AWS_ACCESS_KEY_ID'] = s3_credentials['access_key_id']
  ENV['S3_AWS_SECRET_ACCESS_KEY'] = s3_credentials['secret_access_key']
  ENV['S3_AWS_REGION'] = s3_credentials['region']
  ENV['S3_AWS_BUCKET_NAME'] = s3_credentials['bucket']
  Rails.logger.debug 'Set S3_AWS... ENV variables via vcap_services.rb'
end

def set_redis!(vcap_services_json)
  redis_settings = vcap_services_json['aws-elasticache-redis']
  return false if redis_settings.blank?

  redis_credentials = redis_settings[0]['credentials']
  raise StandardError, 'Redis credentials could not be derived from Cloud Foundry VCAP_SERVICES' if redis_credentials.blank?

  # use `rediss://` to force HTTPS
  ENV['REDIS_URL'] = redis_credentials['uri'].gsub('redis:', 'rediss:')
  Rails.logger.debug 'Set REDIS_URL ENV variable via vcap_services.rb'
end

if vcap_services.present?
  vcap_services_json = JSON.parse(vcap_services)

  # Set ENV variables
  set_s3!(vcap_services_json)
  set_redis!(vcap_services_json)
end
