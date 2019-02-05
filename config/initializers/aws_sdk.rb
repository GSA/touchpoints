creds = Aws::Credentials.new(ENV.fetch("AWS_ACCESS_KEY_ID"), ENV.fetch("AWS_SECRET_ACCESS_KEY"))
Aws::Rails.add_action_mailer_delivery_method(:aws_sdk, credentials: creds, region: 'us-east-1')
