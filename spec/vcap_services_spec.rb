# frozen_string_literal: true

require 'rails_helper'
require_relative '../config/vcap_services'

RSpec.describe Touchpoints::VcapServices do
  around do |example|
    original_environment = ENV.to_h
    example.run
  ensure
    ENV.replace(original_environment)
  end

  describe '.set_s3!' do
    it 'maps the public and uploads S3 credentials' do
      services = {
        's3' => [
          {
            'plan' => 'basic-public',
            'credentials' => {
              'access_key_id' => 'public-access-key',
              'secret_access_key' => 'public-secret-key',
              'region' => 'us-east-1',
              'bucket' => 'public-bucket',
            },
          },
          {
            'plan' => 'basic',
            'credentials' => {
              'access_key_id' => 'uploads-access-key',
              'secret_access_key' => 'uploads-secret-key',
              'region' => 'us-west-2',
              'bucket' => 'uploads-bucket',
            },
          },
        ],
      }

      described_class.set_s3!(services)

      expect(ENV.to_h).to include(
        'S3_AWS_ACCESS_KEY_ID' => 'public-access-key',
        'S3_AWS_SECRET_ACCESS_KEY' => 'public-secret-key',
        'S3_AWS_REGION' => 'us-east-1',
        'S3_AWS_BUCKET_NAME' => 'public-bucket',
        'S3_UPLOADS_AWS_ACCESS_KEY_ID' => 'uploads-access-key',
        'S3_UPLOADS_AWS_SECRET_ACCESS_KEY' => 'uploads-secret-key',
        'S3_UPLOADS_AWS_REGION' => 'us-west-2',
        'S3_UPLOADS_AWS_BUCKET_NAME' => 'uploads-bucket',
      )
    end

    it 'does not change the environment when no S3 service is present' do
      ENV['S3_AWS_BUCKET_NAME'] = 'existing-bucket'

      expect(described_class.set_s3!({})).to be_nil
      expect(ENV['S3_AWS_BUCKET_NAME']).to eq('existing-bucket')
    end

    it 'raises when a required S3 service plan is missing credentials' do
      services = { 's3' => [{ 'plan' => 'basic-public', 'credentials' => {} }] }

      expect { described_class.set_s3!(services) }
        .to raise_error(StandardError, /s3 credentials could not be derived/)
    end
  end

  describe '.set_redis!' do
    it 'sets REDIS_URL to use TLS' do
      services = {
        'aws-elasticache-redis' => [
          { 'credentials' => { 'uri' => 'redis://:password@example.com:6379' } },
        ],
      }

      described_class.set_redis!(services)

      expect(ENV['REDIS_URL']).to eq('rediss://:password@example.com:6379')
    end

    it 'does not change the environment when no Redis service is present' do
      ENV['REDIS_URL'] = 'rediss://existing.example.com:6379'

      expect(described_class.set_redis!({})).to be_nil
      expect(ENV['REDIS_URL']).to eq('rediss://existing.example.com:6379')
    end

    it 'raises when Redis credentials are missing' do
      services = { 'aws-elasticache-redis' => [{ 'credentials' => {} }] }

      expect { described_class.set_redis!(services) }
        .to raise_error(StandardError, /Redis credentials could not be derived/)
    end
  end

  describe '.set_secrets!' do
    it 'maps application secrets to environment variables' do
      services = {
        'user-provided' => [
          {
            'name' => 'touchpoints-secrets',
            'credentials' => {
              'api' => {
                'username' => 'api-user',
                'password' => 'api-password',
              },
              'ses' => {
                'region' => 'us-east-1',
                'access_key_id' => 'ses-access-key',
                'secret_access_key' => 'ses-secret-key',
              },
              'rails_active_record' => {
                'primary_key' => 'primary-key',
                'deterministic_key' => 'deterministic-key',
                'key_derivation_salt' => 'derivation-salt',
              },
              'new_relic' => {
                'key' => 'new-relic-key',
              },
              'login_gov' => {
                'private_key' => 'login-key',
              },
              'email_sender' => 'sender@example.gov',
              'gtm_container_id' => 'gtm-container',
            },
          },
        ],
      }

      described_class.set_secrets!(services)

      expect(ENV.to_h).to include(
        'API_HTTP_USERNAME' => 'api-user',
        'API_HTTP_PASSWORD' => 'api-password',
        'LOGIN_GOV_PRIVATE_KEY' => 'login-key',
        'AWS_SES_REGION' => 'us-east-1',
        'AWS_SES_ACCESS_KEY_ID' => 'ses-access-key',
        'AWS_SES_SECRET_ACCESS_KEY' => 'ses-secret-key',
        'TOUCHPOINTS_EMAIL_SENDER' => 'sender@example.gov',
        'NEW_RELIC_KEY' => 'new-relic-key',
        'RAILS_ACTIVE_RECORD_PRIMARY_KEY' => 'primary-key',
        'RAILS_ACTIVE_RECORD_DETERMINISTIC_KEY' => 'deterministic-key',
        'RAILS_ACTIVE_RECORD_KEY_DERIVATION_SALT' => 'derivation-salt',
        'TOUCHPOINTS_GTM_CONTAINER_ID' => 'gtm-container',
      )
    end

    it 'raises when the secrets service is missing' do
      expect { described_class.set_secrets!({}) }
        .to raise_error(StandardError, /secrets service/)
    end

    it 'raises when a startup secret is missing' do
      services = {
        'user-provided' => [
          {
            'name' => 'touchpoints-secrets',
            'credentials' => {
              'api' => { 'username' => 'api-user' },
            },
          },
        ],
      }

      expect { described_class.set_secrets!(services) }
        .to raise_error(StandardError, /API_HTTP_PASSWORD/)
    end
  end
end
