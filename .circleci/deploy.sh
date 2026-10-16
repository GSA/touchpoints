#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")/cf-deploy-helpers.sh"

TARGET_ENV="${1:-}"

case "$TARGET_ENV" in
  production)
    app_name="touchpoints"
    manifest_path="touchpoints.yml"
    cf login -a "$CF_API_ENDPOINT" -u "$CF_PRODUCTION_SPACE_DEPLOYER_USERNAME" -p "$CF_PRODUCTION_SPACE_DEPLOYER_PASSWORD" -o "$CF_ORG" -s prod
    ./.circleci/sync-login-gov-env.sh "$app_name"
    ;;
  demo)
    app_name="touchpoints-demo"
    manifest_path="touchpoints-demo.yml"
    cf login -a "$CF_API_ENDPOINT" -u "$CF_USERNAME" -p "$CF_PASSWORD" -o "$CF_ORG" -s "$CF_SPACE"
    ;;
  staging)
    app_name="touchpoints-staging"
    manifest_path="touchpoints-staging.yml"
    cf login -a "$CF_API_ENDPOINT" -u "$CF_USERNAME" -p "$CF_PASSWORD" -o "$CF_ORG" -s "$CF_SPACE"
    ;;
  *)
    echo "Usage: $0 <production|demo|staging>" >&2
    exit 2
    ;;
esac

acquire_deploy_lock "$app_name"
trap 'release_deploy_lock "$app_name"' EXIT
wait_for_no_active_deployment "$app_name"

cf push "$app_name" -f "$manifest_path" --strategy rolling -t 180 --no-wait
wait_for_deployment_complete "$app_name"
