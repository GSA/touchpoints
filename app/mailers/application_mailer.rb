class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("TOUCHPOINTS_EMAIL_SENDER")
  layout 'mailer'
  @@header_logo = File.read("#{Rails.root}/app/assets/images/touchpoints-logo-@2x.png")
end
