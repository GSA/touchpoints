# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, 'tmp/cron_log.log'

every 1.day do
  runner 'ScheduledTask.check_expiring_forms'
end

# Notifications for Responses
every 1.day, at: '09:00pm' do
  rake 'scheduled_jobs:send_daily_notifications'
end

every :monday, at: '05:00am' do
  rake 'scheduled_jobs:send_weekly_notifications'
end

# Admin Emails
every 1.day, at: '10:00pm' do
  rake 'scheduled_jobs:deactivate_inactive_users'
end

every 1.day, at: '10:15pm' do
  rake 'scheduled_jobs:send_one_week_until_inactivation_warning'
end

every 1.day, at: '10:30pm' do
  rake 'scheduled_jobs:send_two_weeks_until_inactivation_warning'
end

every 1.day, at: '11:00pm' do
  rake 'scheduled_jobs:archive_surveys'
end
