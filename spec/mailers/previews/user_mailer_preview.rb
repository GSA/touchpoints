# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/submission_notification
  def submission_notification
    UserMailerMailer.submission_notification
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/admin_summary
  def admin_summary
    UserMailerMailer.admin_summary
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/webmaster_summary
  def webmaster_summary
    UserMailerMailer.webmaster_summary
  end
end
