# Try to get S3 settings from Cloud Foundry's VCAP_SERVICES object
vcap_services = ENV["VCAP_SERVICES"]

# If Touchpoints is hosted somewhere besides Cloud Foundry
# these ENV variables can be specified directly, instead of using VCAP_SERVICES
return false unless vcap_services.present?

vcap_services_json = JSON.parse(vcap_services)

s3_settings = vcap_services_json["s3"]
return false unless s3_settings.present?

s3_credentials = s3_settings[0]["credentials"]
unless s3_credentials.present?
  raise Exception.new("s3 credentials could not be derived from Cloud Foundry VCAP_SERVICES")
end


# Set ENV variables based on Cloud Foundry's VCAP_SERVICES object
# Note: this is done this way to allow Touchpoints to use ENV variables
# on other platforms as well.
ENV["S3_AWS_ACCESS_KEY_ID"] = s3_credentials["access_key_id"]
ENV["S3_AWS_SECRET_ACCESS_KEY"] = s3_credentials["secret_access_key"]
ENV["S3_AWS_REGION"] = s3_credentials["region"]
ENV["S3_AWS_BUCKET_NAME"] = s3_credentials["bucket"]
