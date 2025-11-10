#!/usr/bin/env bash

# Fail if anything within this script returns
# a non-zero exit code
set -e

# Set # of failures to 0
F=0

function run_production_tasks() {
	# === PRODUCTION environment ===================================================
	echo "Running tasks in Production..."

	PROD_TASK="cf run-task touchpoints-production-sidekiq-worker --wait -c" 
	# Users
	$PROD_TASK "rake scheduled_jobs:send_one_week_until_inactivation_warning" || F=$((F+=1))
	$PROD_TASK "rake scheduled_jobs:send_two_weeks_until_inactivation_warning" || F=$((F+=1))
	$PROD_TASK "rake scheduled_jobs:deactivate_inactive_users" || F=$((F+=1))

	# Forms
	# $PROD_TASK "rake scheduled_jobs:send_daily_notifications" || F=$((F+=1))
	# $PROD_TASK "rake scheduled_jobs:send_weekly_notifications" || F=$((F+=1))
	# $PROD_TASK "rake scheduled_jobs:check_expiring_forms" || F=$((F+=1))
	# $PROD_TASK "rake scheduled_jobs:archive_forms" || F=$((F+=1))
	$PROD_TASK "rake scheduled_jobs:notify_form_managers_of_inactive_forms" || F=$((F+=1))
	# $PROD_TASK "rake scheduled_jobs:delete_submissions_trash" || F=$((F+=1))
	echo "Production tasks have completed."
}


function run_staging_tasks() {
	# === STAGING environment ======================================================
	echo "Running tasks in Staging..."

	STAGING_TASK="cf run-task touchpoints-staging-sidekiq-worker --wait -c"

	# Users
	$STAGING_TASK "rake scheduled_jobs:send_one_week_until_inactivation_warning" || F=$((F+=1))
	$STAGING_TASK "rake scheduled_jobs:send_two_weeks_until_inactivation_warning" || F=$((F+=1))
	$STAGING_TASK "rake scheduled_jobs:deactivate_inactive_users" || F=$((F+=1))

	# Forms
	$STAGING_TASK "rake scheduled_jobs:send_daily_notifications" || F=$((F+=1))
	$STAGING_TASK "rake scheduled_jobs:send_weekly_notifications" || F=$((F+=1))
	$STAGING_TASK "rake scheduled_jobs:check_expiring_forms" || F=$((F+=1))
	$STAGING_TASK "rake scheduled_jobs:archive_forms" || F=$((F+=1))
	$STAGING_TASK "rake scheduled_jobs:notify_form_managers_of_inactive_forms" || F=$((F+=1))
	# $STAGING_TASK "rake scheduled_jobs:delete_submissions_trash" || F=$((F+=1))

	echo "Staging tasks have completed."
}

function run_demo_tasks() {
	# === DEMO environment =========================================================
	echo "Running tasks in Demo..."
	DEMO_TASK="cf run-task touchpoints-demo-sidekiq-worker --wait -c"

	# Users
	$DEMO_TASK "rake scheduled_jobs:send_one_week_until_inactivation_warning" || F=$((F+=1))
	$DEMO_TASK "rake scheduled_jobs:send_two_weeks_until_inactivation_warning" || F=$((F+=1))
	$DEMO_TASK "rake scheduled_jobs:deactivate_inactive_users" || F=$((F+=1))

	# Forms
	$DEMO_TASK "rake scheduled_jobs:send_daily_notifications" || F=$((F+=1))
	$DEMO_TASK "rake scheduled_jobs:send_weekly_notifications" || F=$((F+=1))
	$DEMO_TASK "rake scheduled_jobs:check_expiring_forms" || F=$((F+=1))
	$DEMO_TASK "rake scheduled_jobs:archive_forms" || F=$((F+=1))
	$DEMO_TASK "rake scheduled_jobs:notify_form_managers_of_inactive_forms" || F=$((F+=1))
	# $DEMO_TASK "rake scheduled_jobs:delete_submissions_trash" || F=$((F+=1))

	echo "Demo tasks have completed."
}

echo "Logging into cloud.gov non-prod"
cf login -a $CF_API_ENDPOINT -u $CF_USERNAME -p $CF_PASSWORD -o $CF_ORG -s $CF_SPACE
run_staging_tasks
run_demo_tasks
cf logout

echo "Logging into cloud.gov production environment"
cf login -a $CF_API_ENDPOINT -u $CF_PRODUCTION_SPACE_DEPLOYER_USERNAME -p $CF_PRODUCTION_SPACE_DEPLOYER_PASSWORD -o $CF_ORG -s prod
run_production_tasks
cf logout

echo "$0 exiting with failure count: $F"
exit $F