#!/usr/bin/env bash

# Fail if anything within this script returns
# a non-zero exit code
set -e

# Acquire a deployment lock using CF environment variable
# This prevents multiple pipelines from deploying simultaneously
acquire_deploy_lock() {
  local app_name="$1"
  local lock_name="DEPLOY_LOCK"
  local lock_value="${CIRCLE_BUILD_NUM:-$$}_$(date +%s)"
  local max_wait=600  # 10 minutes max
  local wait_interval=30
  local waited=0
  
  echo "Attempting to acquire deploy lock for $app_name..."
  
  while [ $waited -lt $max_wait ]; do
    # Check if there's an existing lock
    local current_lock=$(cf env "$app_name" 2>/dev/null | grep "$lock_name:" | awk '{print $2}' || echo "")
    
    if [ -z "$current_lock" ] || [ "$current_lock" == "null" ]; then
      # No lock exists, try to acquire it
      echo "Setting deploy lock: $lock_value"
      cf set-env "$app_name" "$lock_name" "$lock_value" > /dev/null 2>&1 || true
      sleep 5  # Small delay to handle race conditions
      
      # Verify we got the lock
      current_lock=$(cf env "$app_name" 2>/dev/null | grep "$lock_name:" | awk '{print $2}' || echo "")
      if [ "$current_lock" == "$lock_value" ]; then
        echo "Deploy lock acquired: $lock_value"
        return 0
      fi
    fi
    
    # Check if lock is stale (older than 15 minutes)
    local lock_time=$(echo "$current_lock" | cut -d'_' -f2)
    local now=$(date +%s)
    if [ -n "$lock_time" ] && [ $((now - lock_time)) -gt 900 ]; then
      echo "Stale lock detected (age: $((now - lock_time))s), clearing..."
      cf unset-env "$app_name" "$lock_name" > /dev/null 2>&1 || true
      continue
    fi
    
    echo "Deploy lock held by another process ($current_lock), waiting ${wait_interval}s... (waited ${waited}s)"
    sleep $wait_interval
    waited=$((waited + wait_interval))
  done
  
  echo "Warning: Could not acquire lock after ${max_wait}s, proceeding anyway..."
  return 0
}

# Release the deployment lock
release_deploy_lock() {
  local app_name="$1"
  local lock_name="DEPLOY_LOCK"
  echo "Releasing deploy lock for $app_name..."
  cf unset-env "$app_name" "$lock_name" > /dev/null 2>&1 || true
}

# Wait for any in-progress deployments to complete before starting
wait_for_deployment() {
  local app_name="$1"
  local max_wait=800  # 13 minutes and 20 seconds max
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

# Wait for the current deployment to fully complete (all instances replaced)
wait_for_deployment_complete() {
  local app_name="$1"
  local max_wait=900  # 15 minutes max for full deployment
  local wait_interval=15
  local waited=0
  
  echo "Waiting for deployment of $app_name to complete..."
  
  local app_guid=$(cf app "$app_name" --guid)
  
  while [ $waited -lt $max_wait ]; do
    # Get the most recent deployment status
    local deployment_info=$(cf curl "/v3/deployments?app_guids=${app_guid}&order_by=-created_at&per_page=1" 2>/dev/null)
    local status=$(echo "$deployment_info" | grep -o '"value":"[^"]*"' | head -1 | cut -d'"' -f4 || echo "")
    local reason=$(echo "$deployment_info" | grep -o '"reason":"[^"]*"' | head -1 | cut -d'"' -f4 || echo "")
    
    if [ "$status" == "FINALIZED" ]; then
      if [ "$reason" == "DEPLOYED" ]; then
        echo "✓ Deployment completed successfully"
        return 0
      elif [ "$reason" == "CANCELED" ]; then
        echo "✗ Deployment was canceled"
        return 1
      else
        echo "✗ Deployment finalized with reason: $reason"
        return 1
      fi
    fi
    
    if [ "$status" == "ACTIVE" ]; then
      echo "Deployment in progress (status: $status), waiting ${wait_interval}s... (waited ${waited}s of ${max_wait}s)"
    else
      echo "Deployment status: $status, reason: $reason"
    fi
    
    sleep $wait_interval
    waited=$((waited + wait_interval))
  done
  
  echo "Warning: Timed out waiting for deployment to complete after ${max_wait}s"
  return 1
}

# Run migrations as a CF task and wait for completion
run_migrations() {
  local app_name="$1"
  local max_wait=1800  # 30 minutes max for migrations
  local wait_interval=10
  local waited=0
  
  echo "Running database migrations for $app_name..."
  
  # Start migration task
  local task_output=$(cf run-task "$app_name" --command "bundle exec rails db:migrate" --name "pre-deploy-migrations" 2>&1)
  echo "$task_output"
  
  # Extract task ID from output
  local task_id=$(echo "$task_output" | grep -oE 'task id:[[:space:]]+[0-9]+' | grep -oE '[0-9]+' || echo "")
  
  if [ -z "$task_id" ]; then
    echo "Warning: Could not determine task ID, checking tasks list..."
    sleep 5
    task_id=$(cf tasks "$app_name" | grep "pre-deploy-migrations" | grep "RUNNING" | head -1 | awk '{print $1}')
  fi
  
  if [ -z "$task_id" ]; then
    echo "Error: Failed to start migration task"
    return 1
  fi
  
  echo "Migration task started with ID: $task_id"
  echo "Waiting for migrations to complete..."
  
  # Wait for task to complete
  while [ $waited -lt $max_wait ]; do
    local task_state=$(cf tasks "$app_name" | grep "^$task_id " | awk '{print $3}')
    
    if [ "$task_state" == "SUCCEEDED" ]; then
      echo "✓ Migrations completed successfully"
      return 0
    elif [ "$task_state" == "FAILED" ]; then
      echo "✗ Migration task failed. Checking logs..."
      cf logs "$app_name" --recent | grep "pre-deploy-migrations" | tail -50
      return 1
    fi
    
    if [ $((waited % 30)) -eq 0 ]; then
      echo "Migration task still running (state: $task_state, waited ${waited}s)..."
    fi
    
    sleep $wait_interval
    waited=$((waited + wait_interval))
  done
  
  echo "Error: Migration task did not complete within ${max_wait}s"
  cf logs "$app_name" --recent | grep "pre-deploy-migrations" | tail -50
  return 1
}

# Retry function to handle staging and deployment conflicts
cf_push_with_retry() {
  local app_name="$1"
  local manifest_path="${2:-}"
  local run_migrations="${3:-false}"
  local max_retries=5
  local retry_delay=90
  
  # Run migrations first if requested
  if [ "$run_migrations" == "true" ]; then
    if ! run_migrations "$app_name"; then
      echo "Error: Migrations failed, aborting deployment"
      return 1
    fi
  fi
  
  # Ensure CircleCI-built Rust library is present
  if [ -f "ext/widget_renderer/target/release/libwidget_renderer.so" ]; then
    echo "CircleCI-built Rust library found, will be included in deployment"
    file ext/widget_renderer/target/release/libwidget_renderer.so
    readelf -n ext/widget_renderer/target/release/libwidget_renderer.so | grep "Build ID" || true
  else
    echo "WARNING: No CircleCI-built Rust library found at ext/widget_renderer/target/release/libwidget_renderer.so"
  fi
  
  # Acquire lock first
  acquire_deploy_lock "$app_name"
  
  # Ensure lock is released on exit
  trap "release_deploy_lock '$app_name'" EXIT
  
  # Wait for any in-progress deployment
  wait_for_deployment "$app_name"
  
  for i in $(seq 1 $max_retries); do
    echo "Attempt $i of $max_retries to push $app_name..."
    local exit_code=0

    set +e
    if [ -n "$manifest_path" ]; then
      echo "Using manifest: $manifest_path"
      cf push "$app_name" -f "$manifest_path" --strategy rolling -t 180 --no-wait
    else
      cf push "$app_name" --strategy rolling -t 180 --no-wait
    fi
    exit_code=$?
    set -e

    if [ $exit_code -eq 0 ]; then
      echo "Push initiated successfully, waiting for full deployment to complete..."
      if wait_for_deployment_complete "$app_name"; then
        echo "Successfully deployed $app_name"
        release_deploy_lock "$app_name"
        trap - EXIT  # Clear the trap
        return 0
      else
        echo "Deployment did not complete successfully"
        # Continue to retry logic below
      fi
    fi

    if [ $i -lt $max_retries ]; then
      echo "Push failed or deployment incomplete (exit code: $exit_code), checking for active deployments..."
      
      # Check if there's an active deployment that we should wait for instead of retrying
      local app_guid=$(cf app "$app_name" --guid 2>/dev/null || echo "")
      if [ -n "$app_guid" ]; then
        local active_deployment=$(cf curl "/v3/deployments?app_guids=${app_guid}&status_values=ACTIVE" 2>/dev/null | grep -c '"ACTIVE"' || echo "0")
        
        if [ "$active_deployment" -gt 0 ]; then
          echo "Active deployment detected, waiting for it to complete instead of retrying..."
          if wait_for_deployment_complete "$app_name"; then
            echo "Existing deployment completed successfully"
            release_deploy_lock "$app_name"
            trap - EXIT
            return 0
          fi
          echo "Existing deployment did not complete successfully, will retry..."
        fi
      fi
      
      echo "Waiting ${retry_delay}s before retry..."
      sleep $retry_delay
      # Re-check for in-progress deployments before retrying
      wait_for_deployment "$app_name"
    fi
  done
  
  release_deploy_lock "$app_name"
  trap - EXIT  # Clear the trap
  echo "Failed to push $app_name after $max_retries attempts"
  return 1
}

if [ "${CIRCLE_BRANCH}" == "production" ]
then
  echo "Logging into cloud.gov"
  # Log into CF and push
  cf login -a $CF_API_ENDPOINT -u $CF_PRODUCTION_SPACE_DEPLOYER_USERNAME -p $CF_PRODUCTION_SPACE_DEPLOYER_PASSWORD -o $CF_ORG -s prod
  echo "PUSHING web servers to Production..."
  echo "Syncing Login.gov environment variables..."
  ./.circleci/sync-login-gov-env.sh touchpoints
  cf_push_with_retry touchpoints touchpoints.yml false
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
  cf_push_with_retry touchpoints-demo "" true
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
  cf_push_with_retry touchpoints-staging "" true
  echo "Push to Staging Complete."
else
  echo "Not on the develop branch."
fi
