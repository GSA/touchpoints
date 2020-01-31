# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, "tmp/cron_log.log"

every 1.days do
   runner "ScheduledTask.check_expiring_touchpoints"
end
