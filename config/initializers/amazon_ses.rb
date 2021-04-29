Aws::Rails.add_action_mailer_delivery_method(:ses,
  access_key_id: ENV['AWS_SES_ACCESS_KEY_ID'],
  secret_access_key: ENV['AWS_SES_SECRET_ACCESS_KEY'],
  region: ENV['AWS_SES_REGION']
)
