namespace :scheduled_jobs do
  task :send_daily_notifications do
    Submission.send_daily_notifications
  end

  task :send_weekly_notifications do
    Submission.send_weekly_notifications
  end

  task :deactivate_inactive_users do
    User.deactivate_inactive_accounts
  end

  task :send_one_week_until_inactivation_warning do
    User.send_account_deactivation_notifications(7)
  end

  task :send_two_weeks_until_inactivation_warning do
    User.send_account_deactivation_notifications(14)
  end
end
