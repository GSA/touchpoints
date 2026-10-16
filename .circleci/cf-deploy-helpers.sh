#!/usr/bin/env bash

set -euo pipefail

deployment_lock_value() {
  printf '%s_%s' "${CIRCLE_WORKFLOW_ID:-${CIRCLE_BUILD_NUM:-$$}}" "$(date +%s)"
}

owns_deployment_lock() {
  local current_lock="$1"
  local workflow_id="${CIRCLE_WORKFLOW_ID:-}"

  [ -n "$workflow_id" ] && [[ "$current_lock" == "${workflow_id}_"* ]]
}

deployment_lock() {
  local app_name="$1"
  cf env "$app_name" 2>/dev/null | awk -F ': ' '/^[[:space:]]*DEPLOY_LOCK:/ { print $2; exit }'
}

acquire_deploy_lock() {
  local app_name="$1"
  local lock_value
  lock_value="$(deployment_lock_value)"
  local max_wait=1200
  local wait_interval=30
  local waited=0

  echo "Attempting to acquire deployment lock for $app_name..."
  while [ "$waited" -lt "$max_wait" ]; do
    local current_lock
    current_lock="$(deployment_lock "$app_name")"

    if [ -z "$current_lock" ] || owns_deployment_lock "$current_lock"; then
      cf set-env "$app_name" DEPLOY_LOCK "$lock_value" >/dev/null
      sleep 5
      current_lock="$(deployment_lock "$app_name")"
      if [ "$current_lock" = "$lock_value" ] || owns_deployment_lock "$current_lock"; then
        echo "Deployment lock acquired: $current_lock"
        return 0
      fi
    fi

    local lock_time="${current_lock##*_}"
    local now
    now="$(date +%s)"
    if [[ "$lock_time" =~ ^[0-9]+$ ]] && [ $((now - lock_time)) -gt 7200 ]; then
      echo "Clearing stale deployment lock: $current_lock"
      cf unset-env "$app_name" DEPLOY_LOCK >/dev/null
      continue
    fi

    echo "Deployment lock held by ${current_lock:-another process}; waiting ${wait_interval}s..."
    sleep "$wait_interval"
    waited=$((waited + wait_interval))
  done

  echo "Could not acquire deployment lock after ${max_wait}s" >&2
  return 1
}

release_deploy_lock() {
  local app_name="$1"
  local current_lock
  current_lock="$(deployment_lock "$app_name")"

  if owns_deployment_lock "$current_lock" || [ "${CIRCLE_WORKFLOW_ID:-}" = "" ]; then
    echo "Releasing deployment lock for $app_name..."
    cf unset-env "$app_name" DEPLOY_LOCK >/dev/null || true
  fi
}

wait_for_no_active_deployment() {
  local app_name="$1"
  local max_wait=900
  local wait_interval=15
  local waited=0
  local app_guid
  app_guid="$(cf app "$app_name" --guid)"

  echo "Checking for active deployments of $app_name..."
  while [ "$waited" -lt "$max_wait" ]; do
    local deployments
    deployments="$(cf curl "/v3/deployments?app_guids=${app_guid}&status_values=ACTIVE")"
    if ! grep -Eq '"(state|status|value)":"ACTIVE"' <<<"$deployments"; then
      return 0
    fi

    echo "Deployment is still active; waiting ${wait_interval}s..."
    sleep "$wait_interval"
    waited=$((waited + wait_interval))
  done

  echo "Timed out waiting for an active deployment of $app_name" >&2
  return 1
}

wait_for_deployment_complete() {
  local app_name="$1"
  local max_wait=900
  local wait_interval=15
  local waited=0
  local app_guid
  app_guid="$(cf app "$app_name" --guid)"

  echo "Waiting for deployment of $app_name to complete..."
  while [ "$waited" -lt "$max_wait" ]; do
    local deployment_info status reason
    deployment_info="$(cf curl "/v3/deployments?app_guids=${app_guid}&order_by=-created_at&per_page=1")"
    status="$(grep -o '"value":"[^"]*"' <<<"$deployment_info" | head -1 | cut -d'"' -f4 || true)"
    reason="$(grep -o '"reason":"[^"]*"' <<<"$deployment_info" | head -1 | cut -d'"' -f4 || true)"

    if [ "$status" = "FINALIZED" ]; then
      if [ "$reason" = "DEPLOYED" ]; then
        echo "Deployment completed successfully"
        return 0
      fi
      echo "Deployment finalized with reason: ${reason:-unknown}" >&2
      return 1
    fi

    echo "Deployment status: ${status:-unknown}; waiting ${wait_interval}s..."
    sleep "$wait_interval"
    waited=$((waited + wait_interval))
  done

  echo "Timed out waiting for deployment of $app_name" >&2
  return 1
}

wait_for_task() {
  local app_name="$1"
  local task_id="$2"
  local max_wait=1800
  local wait_interval=10
  local waited=0

  echo "Waiting for migration task $task_id..."
  while [ "$waited" -lt "$max_wait" ]; do
    local task_state
    task_state="$(cf tasks "$app_name" | awk -v id="$task_id" '$1 == id { print $3; exit }')"
    case "$task_state" in
      SUCCEEDED)
        echo "Migrations completed successfully"
        return 0
        ;;
      FAILED)
        echo "Migration task failed" >&2
        cf logs "$app_name" --recent || true
        return 1
        ;;
    esac

    echo "Migration task state: ${task_state:-unknown}; waiting ${wait_interval}s..."
    sleep "$wait_interval"
    waited=$((waited + wait_interval))
  done

  echo "Migration task did not complete within ${max_wait}s" >&2
  cf logs "$app_name" --recent || true
  return 1
}
