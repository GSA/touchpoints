#!/usr/bin/env bash

# Fail if anything within this script returns
# a non-zero exit code
set -e

echo "Logging into cloud.gov"
cf login -a $CF_API_ENDPOINT -u $CF_USERNAME -p $CF_PASSWORD -o $CF_ORG -s $CF_SPACE

#
# === STAGING environment ======================================================
#

echo "Running tasks in Staging..."

# Users
cf run-task touchpoints-staging-sidekiq-worker -c "rake scheduled_jobs:send_one_week_until_inactivation_warning"
cf run-task touchpoints-staging-sidekiq-worker -c "rake scheduled_jobs:send_two_weeks_until_inactivation_warning"
cf run-task touchpoints-staging-sidekiq-worker -c "rake scheduled_jobs:deactivate_inactive_users"

# Forms
cf run-task touchpoints-staging-sidekiq-worker -c "rake scheduled_jobs:send_daily_notifications"
cf run-task touchpoints-staging-sidekiq-worker -c "rake scheduled_jobs:send_weekly_notifications"
cf run-task touchpoints-staging-sidekiq-worker -c "rake scheduled_jobs:check_expiring_forms"
cf run-task touchpoints-staging-sidekiq-worker -c "rake scheduled_jobs:archive_forms"
cf run-task touchpoints-staging-sidekiq-worker -c "rake scheduled_jobs:notify_form_managers_of_inactive_forms"
cf run-task touchpoints-staging-sidekiq-worker -c "rake scheduled_jobs:delete_submissions_trash"

echo "Staging tasks have completed."

#
# === DEMO environment =========================================================
#

echo "Running tasks in Demo..."

# Users
cf run-task touchpoints-demo-sidekiq-worker -c "rake scheduled_jobs:send_one_week_until_inactivation_warning"
cf run-task touchpoints-demo-sidekiq-worker -c "rake scheduled_jobs:send_two_weeks_until_inactivation_warning"
cf run-task touchpoints-demo-sidekiq-worker -c "rake scheduled_jobs:deactivate_inactive_users"

# Forms
cf run-task touchpoints-demo-sidekiq-worker -c "rake scheduled_jobs:send_daily_notifications"
cf run-task touchpoints-demo-sidekiq-worker -c "rake scheduled_jobs:send_weekly_notifications"
cf run-task touchpoints-demo-sidekiq-worker -c "rake scheduled_jobs:check_expiring_forms"
cf run-task touchpoints-demo-sidekiq-worker -c "rake scheduled_jobs:archive_forms"
cf run-task touchpoints-demo-sidekiq-worker -c "rake scheduled_jobs:notify_form_managers_of_inactive_forms"
cf run-task touchpoints-demo-sidekiq-worker -c "rake scheduled_jobs:delete_submissions_trash"

echo "Demo tasks have completed."

cf logout

#
# === PRODUCTION environment ===================================================
#

echo "Logging into cloud.gov"
cf login -a $CF_API_ENDPOINT -u $CF_PRODUCTION_SPACE_DEPLOYER_USERNAME -p $CF_PRODUCTION_SPACE_DEPLOYER_PASSWORD -o $CF_ORG -s prod

echo "Running tasks in Production..."

# Users
cf run-task touchpoints-production-sidekiq-worker -c "rake scheduled_jobs:send_one_week_until_inactivation_warning"
cf run-task touchpoints-production-sidekiq-worker -c "rake scheduled_jobs:send_two_weeks_until_inactivation_warning"
cf run-task touchpoints-production-sidekiq-worker -c "rake scheduled_jobs:deactivate_inactive_users"

# Forms
# cf run-task touchpoints-production-sidekiq-worker -c "rake scheduled_jobs:send_daily_notifications"
# cf run-task touchpoints-production-sidekiq-worker -c "rake scheduled_jobs:send_weekly_notifications"
# cf run-task touchpoints-production-sidekiq-worker -c "rake scheduled_jobs:check_expiring_forms"
# cf run-task touchpoints-production-sidekiq-worker -c "rake scheduled_jobs:archive_forms"
cf run-task touchpoints-production-sidekiq-worker -c "rake scheduled_jobs:notify_form_managers_of_inactive_forms"
cf run-task touchpoints-production-sidekiq-worker -c "rake scheduled_jobs:delete_submissions_trash"

echo "Production tasks have completed."

cf logout
