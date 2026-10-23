#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")/cf-deploy-helpers.sh"

TARGET_ENV="${1:-}"

case "$TARGET_ENV" in
  production)
    app_name="touchpoints"
    migration_app="touchpoints-migrations"
    migration_manifest="touchpoints-migrations.yml"
    cf login -a "$CF_API_ENDPOINT" -u "$CF_PRODUCTION_SPACE_DEPLOYER_USERNAME" -p "$CF_PRODUCTION_SPACE_DEPLOYER_PASSWORD" -o "$CF_ORG" -s prod
    ;;
  demo)
    app_name="touchpoints-demo"
    migration_app="touchpoints-demo-migrations"
    migration_manifest="touchpoints-demo-migrations.yml"
    cf login -a "$CF_API_ENDPOINT" -u "$CF_USERNAME" -p "$CF_PASSWORD" -o "$CF_ORG" -s "$CF_SPACE"
    ;;
  staging)
    app_name="touchpoints-staging"
    migration_app="touchpoints-staging-migrations"
    migration_manifest="touchpoints-staging-migrations.yml"
    cf login -a "$CF_API_ENDPOINT" -u "$CF_USERNAME" -p "$CF_PASSWORD" -o "$CF_ORG" -s "$CF_SPACE"
    ;;
  *)
    echo "Usage: $0 <production|demo|staging>" >&2
    exit 2
    ;;
esac

acquire_deploy_lock "$app_name"
trap 'release_deploy_lock "$app_name"' EXIT

# Push the full Rails app as a task-only migration app. `--task` stages a
# droplet for cf run-task without starting app instances or assigning routes.
cf push "$migration_app" -f "$migration_manifest" --task -t 180

task_name="pre-deploy-migrations-${CIRCLE_WORKFLOW_ID:-${CIRCLE_BUILD_NUM:-$$}}"
cf run-task "$migration_app" --command "bundle exec rails db:migrate" --name "$task_name"

# The task is polled by its unique name via CAPI, so there is no need to scrape
# a task id out of the CLI's human-readable output.
wait_for_task "$migration_app" "$task_name"

# Keep the workflow-scoped lock through the worker and web rollout. A failed job
# releases it through the EXIT trap; the web rollout is responsible for release.
trap - EXIT
