# frozen_string_literal: true

# Load credentials from VCAP_SERVICES into system env variables.
# Loads early in the boot process so keep this loader independent of Rails services such as Rails.logger.
module Touchpoints
  module VcapServices
    module_function

    def set_s3!(vcap_services_json)
      s3_settings = vcap_services_json['s3']
      return if s3_settings.blank?

      s3 = s3_settings.find { |instance| instance['plan'] == 'basic-public' }
      s3_credentials = s3 && s3['credentials']
      raise StandardError, 's3 credentials could not be derived from Cloud Foundry VCAP_SERVICES' if s3_credentials.blank?

      ENV['S3_AWS_ACCESS_KEY_ID'] = s3_credentials['access_key_id']
      ENV['S3_AWS_SECRET_ACCESS_KEY'] = s3_credentials['secret_access_key']
      ENV['S3_AWS_REGION'] = s3_credentials['region']
      ENV['S3_AWS_BUCKET_NAME'] = s3_credentials['bucket']

      s3_upload = s3_settings.find { |instance| instance['plan'] == 'basic' }
      s3_upload_credentials = s3_upload && s3_upload['credentials']
      raise StandardError, 's3 credentials could not be derived from Cloud Foundry VCAP_SERVICES' if s3_upload_credentials.blank?

      ENV['S3_UPLOADS_AWS_ACCESS_KEY_ID'] = s3_upload_credentials['access_key_id']
      ENV['S3_UPLOADS_AWS_SECRET_ACCESS_KEY'] = s3_upload_credentials['secret_access_key']
      ENV['S3_UPLOADS_AWS_REGION'] = s3_upload_credentials['region']
      ENV['S3_UPLOADS_AWS_BUCKET_NAME'] = s3_upload_credentials['bucket']
    end

    def set_redis!(vcap_services_json)
      redis_settings = vcap_services_json['aws-elasticache-redis']
      return if redis_settings.blank?

      redis_credentials = redis_settings[0]['credentials']
      raise StandardError, 'Redis credentials could not be derived from Cloud Foundry VCAP_SERVICES' if redis_credentials.blank?

      ENV['REDIS_URL'] = redis_credentials['uri'].gsub('redis:', 'rediss:')
    end

    def set_secrets!(vcap_services_json)
      service = vcap_services_json.fetch('user-provided', []).find do |instance|
        instance['name'] == 'touchpoints-secrets'
      end
      raise StandardError, 'required startup secrets service is missing' if service.blank?

      secrets = service['credentials']
      raise StandardError, 'required startup secrets credentials are missing' if secrets.blank?

      required_secrets = {
        'TURNSTILE_SECRET_KEY' => secrets.dig('turnstile', 'secret_key'),
        'TURNSTILE_SITE_KEY' => secrets.dig('turnstile', 'site_key'),
        'API_HTTP_USERNAME' => secrets.dig('api', 'username'),
        'API_HTTP_PASSWORD' => secrets.dig('api', 'password'),
        'LOGIN_GOV_PRIVATE_KEY' => secrets.dig('login_gov', 'private_key'),
        'AWS_SES_REGION' => secrets.dig('ses', 'region'),
        'AWS_SES_ACCESS_KEY_ID' => secrets.dig('ses', 'access_key_id'),
        'AWS_SES_SECRET_ACCESS_KEY' => secrets.dig('ses', 'secret_access_key'),
        'TOUCHPOINTS_EMAIL_SENDER' => secrets.dig('email_sender'),
        'NEW_RELIC_KEY' => secrets.dig('new_relic', 'key'),
        'RAILS_ACTIVE_RECORD_PRIMARY_KEY' => secrets.dig('rails_active_record', 'primary_key'),
        'RAILS_ACTIVE_RECORD_DETERMINISTIC_KEY' => secrets.dig('rails_active_record', 'deterministic_key'),
        'RAILS_ACTIVE_RECORD_KEY_DERIVATION_SALT' => secrets.dig('rails_active_record', 'key_derivation_salt'),
        'TOUCHPOINTS_GTM_CONTAINER_ID' => secrets.dig('gtm_container_id'),
      }
      missing_secrets = required_secrets.filter_map { |name, value| name unless value.present? }
      raise StandardError, "required startup secrets are missing: #{missing_secrets.join(', ')}" if missing_secrets.present?

      required_secrets.each { |name, value| ENV[name] = value }
    end

    def load!
      vcap_services = ENV.fetch('VCAP_SERVICES', nil)
      return if vcap_services.blank?

      vcap_services_json = JSON.parse(vcap_services)
      set_s3!(vcap_services_json)
      set_redis!(vcap_services_json)
      set_secrets!(vcap_services_json)
    end
  end
end
