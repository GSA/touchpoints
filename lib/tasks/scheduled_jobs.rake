namespace :scheduled_jobs do
  task send_daily_notifications: :environment do
    Submission.send_daily_notifications
  end

  task send_weekly_notifications: :environment do
    Submission.send_weekly_notifications
  end

  task deactivate_inactive_users: :environment do
    User.deactivate_inactive_accounts
  end

  task send_one_week_until_inactivation_warning: :environment do
    User.send_account_deactivation_notifications(7)
  end

  task send_two_weeks_until_inactivation_warning: :environment do
    User.send_account_deactivation_notifications(14)
  end

  task archive_surveys: :environment do
    Form.archive_expired!
  end
end
