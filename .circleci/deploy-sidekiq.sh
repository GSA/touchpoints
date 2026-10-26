#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")/cf-deploy-helpers.sh"

TARGET_ENV="${1:-}"

case "$TARGET_ENV" in
  production)
    lock_app="touchpoints"
    app_name="touchpoints-production-sidekiq-worker"
    manifest_path="touchpoints-sidekiq.yml"
    cf login -a "$CF_API_ENDPOINT" -u "$CF_PRODUCTION_SPACE_DEPLOYER_USERNAME" -p "$CF_PRODUCTION_SPACE_DEPLOYER_PASSWORD" -o "$CF_ORG" -s prod
    ;;
  demo)
    lock_app="touchpoints-demo"
    app_name="touchpoints-demo-sidekiq-worker"
    manifest_path="touchpoints-demo-sidekiq.yml"
    cf login -a "$CF_API_ENDPOINT" -u "$CF_USERNAME" -p "$CF_PASSWORD" -o "$CF_ORG" -s "$CF_SPACE"
    ;;
  staging)
    lock_app="touchpoints-staging"
    app_name="touchpoints-staging-sidekiq-worker"
    manifest_path="touchpoints-staging-sidekiq.yml"
    cf login -a "$CF_API_ENDPOINT" -u "$CF_USERNAME" -p "$CF_PASSWORD" -o "$CF_ORG" -s "$CF_SPACE"
    ;;
  *)
    echo "Usage: $0 <production|demo|staging>" >&2
    exit 2
    ;;
esac

acquire_deploy_lock "$lock_app"
trap 'release_deploy_lock "$lock_app"' EXIT

wait_for_no_active_deployment "$app_name"
cf push "$app_name" -f "$manifest_path" -t 180

# Keep the workflow-scoped lock through the web rollout. A failed job releases it
# through the EXIT trap; deploy.sh releases the lock after its rollout completes.
trap - EXIT
