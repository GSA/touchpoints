class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("TOUCHPOINTS_EMAIL_SENDER")
  layout 'mailer'
end
