#!/usr/bin/env bash

# Fail if anything within this script returns
# a non-zero exit code
set -e

echo "Logging into cloud.gov"
# Log into CF
cf login -a $CF_API_ENDPOINT -u $CF_USERNAME -p $CF_PASSWORD -o $CF_ORG -s $CF_SPACE
echo "Running tasks in Staging..."
cf run-task touchpoints-staging-sidekiq-worker -c "rake scheduled_jobs:archive_surveys"
cf run-task touchpoints-demo-sidekiq-worker -c "rake scheduled_jobs:archive_surveys"
echo "Running tasks complete."
