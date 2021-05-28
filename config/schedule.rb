# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, "tmp/cron_log.log"

every 1.days do
  runner "ScheduledTask.check_expiring_forms"
end

every 1.day, :at => "09:00pm" do
  runner "Submission.send_daily_notifications"
end

every 1.days, :at => "10:00pm" do
  runner "User.deactivate_inactive_accounts"
end

every 1.day, :at => "10:15pm" do
  runner "User.send_account_deactivation_notifications(7)"
end

every 1.days, :at => "10:30pm" do
  runner "User.send_account_deactivation_notifications(14)"
end

every :monday, :at => "05:00am" do
  runner "Submission.send_weekly_notifications"
end
