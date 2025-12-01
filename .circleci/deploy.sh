#!/usr/bin/env bash

# Fail if anything within this script returns
# a non-zero exit code
set -e

# Wait for any in-progress deployments to complete before starting
wait_for_deployment() {
  local app_name="$1"
  local max_wait=600  # 10 minutes max
  local wait_interval=15
  local waited=0
  
  echo "Checking for in-progress deployments of $app_name..."
  
  while [ $waited -lt $max_wait ]; do
    # Get deployment status - look for ACTIVE deployments
    local status=$(cf curl "/v3/deployments?app_guids=$(cf app "$app_name" --guid)&status_values=ACTIVE" 2>/dev/null | grep -o '"state":"[^"]*"' | head -1 || echo "")
    
    if [ -z "$status" ] || [[ "$status" == *'"state":"FINALIZED"'* ]] || [[ "$status" == *'"state":"DEPLOYED"'* ]]; then
      echo "No active deployment in progress, proceeding..."
      return 0
    fi
    
    echo "Deployment in progress ($status), waiting ${wait_interval}s... (waited ${waited}s of ${max_wait}s)"
    sleep $wait_interval
    waited=$((waited + wait_interval))
  done
  
  echo "Warning: Timed out waiting for previous deployment, proceeding anyway..."
  return 0
}

# Retry function to handle staging and deployment conflicts
cf_push_with_retry() {
  local app_name="$1"
  local max_retries=5
  local retry_delay=90
  
  # Wait for any in-progress deployment first
  wait_for_deployment "$app_name"
  
  for i in $(seq 1 $max_retries); do
    echo "Attempt $i of $max_retries to push $app_name..."
    if cf push "$app_name" --strategy rolling; then
      echo "Successfully pushed $app_name"
      return 0
    else
      local exit_code=$?
      if [ $i -lt $max_retries ]; then
        echo "Push failed (exit code: $exit_code), waiting ${retry_delay}s before retry..."
        sleep $retry_delay
        # Re-check for in-progress deployments before retrying
        wait_for_deployment "$app_name"
      fi
    fi
  done
  
  echo "Failed to push $app_name after $max_retries attempts"
  return 1
}

if [ "${CIRCLE_BRANCH}" == "production" ]
then
  echo "Logging into cloud.gov"
  # Log into CF and push
  cf login -a $CF_API_ENDPOINT -u $CF_PRODUCTION_SPACE_DEPLOYER_USERNAME -p $CF_PRODUCTION_SPACE_DEPLOYER_PASSWORD -o $CF_ORG -s prod
  echo "PUSHING web servers to Production..."
  cf_push_with_retry touchpoints
  echo "Push to Production Complete."
else
  echo "Not on the production branch."
fi

if [ "${CIRCLE_BRANCH}" == "main" ]
then
  echo "Logging into cloud.gov"
  # Log into CF and push
  cf login -a $CF_API_ENDPOINT -u $CF_USERNAME -p $CF_PASSWORD -o $CF_ORG -s $CF_SPACE
  echo "Pushing web servers to Demo..."
  cf_push_with_retry touchpoints-demo
  echo "Push to Demo Complete."
else
  echo "Not on the main branch."
fi

if [ "${CIRCLE_BRANCH}" == "develop" ]
then
  echo "Logging into cloud.gov"
  # Log into CF and push
  cf login -a $CF_API_ENDPOINT -u $CF_USERNAME -p $CF_PASSWORD -o $CF_ORG -s $CF_SPACE
  echo "Pushing web servers to Staging..."
  cf_push_with_retry touchpoints-staging
  echo "Push to Staging Complete."
else
  echo "Not on the develop branch."
fi
