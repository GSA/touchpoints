if Rails.env.staging? || Rails.env.production?
  creds = Aws::Credentials.new(ENV.fetch("AWS_ACCESS_KEY_ID"), ENV.fetch("AWS_SECRET_ACCESS_KEY"))
  region = ENV.fetch("AWS_REGION")

  Aws::Rails.add_action_mailer_delivery_method(
    :ses,
    credentials: creds,
    region: region
  )
end
