#!/usr/bin/env bash

# Fail if anything within this script returns
# a non-zero exit code
set -e

# Set # of failures to 0
F=0

function run_scheduled_job() {
  local app=$1
  local job=$2
  cf run-task $app --wait --name $job -c "rake scheduled_jobs:$job" || F=$((F+=1))
}

function run_production_tasks() {
	# === PRODUCTION environment ===================================================
	echo "Running tasks in Production..."

	# Users
	run_scheduled_job "touchpoints-production-sidekiq-worker" "send_one_week_until_inactivation_warning"
	run_scheduled_job "touchpoints-production-sidekiq-worker" "send_two_weeks_until_inactivation_warning"
	run_scheduled_job "touchpoints-production-sidekiq-worker" "deactivate_inactive_users"

	# Forms
	# run_task "touchpoints-production-sidekiq-worker" "rake scheduled_jobs:send_daily_notifications"
	# run_task "touchpoints-production-sidekiq-worker" "rake scheduled_jobs:send_weekly_notifications"
	# run_task "touchpoints-production-sidekiq-worker" "rake scheduled_jobs:check_expiring_forms"
	# run_task "touchpoints-production-sidekiq-worker" "rake scheduled_jobs:archive_forms"
	run_scheduled_job "touchpoints-production-sidekiq-worker" "notify_form_managers_of_inactive_forms"
	# run_task "touchpoints-production-sidekiq-worker" "rake scheduled_jobs:delete_submissions_trash"
	echo "Production tasks have completed."
}


function run_staging_tasks() {
	# === STAGING environment ======================================================
	echo "Running tasks in Staging..."

	# Users
	run_scheduled_job "touchpoints-staging-sidekiq-worker" "send_one_week_until_inactivation_warning"
	run_scheduled_job "touchpoints-staging-sidekiq-worker" "send_two_weeks_until_inactivation_warning"
	run_scheduled_job "touchpoints-staging-sidekiq-worker" "deactivate_inactive_users"

	# Forms
	run_scheduled_job "touchpoints-staging-sidekiq-worker" "send_daily_notifications"
	run_scheduled_job "touchpoints-staging-sidekiq-worker" "send_weekly_notifications"
	run_scheduled_job "touchpoints-staging-sidekiq-worker" "check_expiring_forms"
	run_scheduled_job "touchpoints-staging-sidekiq-worker" "archive_forms"
	run_scheduled_job "touchpoints-staging-sidekiq-worker" "notify_form_managers_of_inactive_forms"
	run_scheduled_job "touchpoints-staging-sidekiq-worker" "delete_submissions_trash"

	echo "Staging tasks have completed."
}

function run_demo_tasks() {
	# === DEMO environment =========================================================
	echo "Running tasks in Demo..."

	# Users
	run_scheduled_job "touchpoints-demo-sidekiq-worker" "send_one_week_until_inactivation_warning"
	run_scheduled_job "touchpoints-demo-sidekiq-worker" "send_two_weeks_until_inactivation_warning"
	run_scheduled_job "touchpoints-demo-sidekiq-worker" "deactivate_inactive_users"

	# Forms
	run_scheduled_job "touchpoints-demo-sidekiq-worker" "send_daily_notifications"
	run_scheduled_job "touchpoints-demo-sidekiq-worker" "send_weekly_notifications"
	run_scheduled_job "touchpoints-demo-sidekiq-worker" "check_expiring_forms"
	run_scheduled_job "touchpoints-demo-sidekiq-worker" "archive_forms"
	run_scheduled_job "touchpoints-demo-sidekiq-worker" "notify_form_managers_of_inactive_forms"
	run_scheduled_job "touchpoints-demo-sidekiq-worker" "delete_submissions_trash"

	echo "Demo tasks have completed."
}

TARGET_ENV="${1:-}"

if [ -z "$TARGET_ENV" ]; then
  echo "Usage: ./.circleci/cron.sh <production|demo|staging>"
  exit 1
fi


case "$TARGET_ENV" in
  production)
    echo "Logging into cloud.gov production environment"
    cf login -a $CF_API_ENDPOINT -u $CF_PRODUCTION_SPACE_DEPLOYER_USERNAME -p $CF_PRODUCTION_SPACE_DEPLOYER_PASSWORD -o $CF_ORG -s prod
    run_production_tasks
    cf logout
    ;;
  demo)
    echo "Logging into cloud.gov non-prod"
    cf login -a $CF_API_ENDPOINT -u $CF_USERNAME -p $CF_PASSWORD -o $CF_ORG -s $CF_SPACE
    run_demo_tasks
    cf logout
    ;;
  staging)
    echo "Logging into cloud.gov non-prod"
    cf login -a $CF_API_ENDPOINT -u $CF_USERNAME -p $CF_PASSWORD -o $CF_ORG -s $CF_SPACE
    run_staging_tasks
    cf logout
    ;;
  *)
    echo "Unknown environment: $TARGET_ENV"
    echo "Usage: ./.circleci/cron.sh <production|demo|staging>"
    exit 1
    ;;
esac

echo "$0 exiting with failure count: $F"
exit $F