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

# touchpoints-{,demo-,staging-}migrations is a persistent, route-less, zero
# -instance app bound to the same database. It uses only the Ruby buildpack
# (no Node, no Rust) since migrations don't need assets or the widget
# renderer, which keeps staging fast. `--no-start` stages the release without
# starting any instance; the task below runs against that staged droplet.
cf push "$migration_app" -f "$migration_manifest" --no-start -t 180

task_name="pre-deploy-migrations-${CIRCLE_WORKFLOW_ID:-${CIRCLE_BUILD_NUM:-$$}}"
task_output="$(cf run-task "$migration_app" --command "bundle exec rails db:migrate" --name "$task_name" 2>&1)"
printf '%s\n' "$task_output"
task_id="$(grep -oE 'task id:[[:space:]]*[0-9]+' <<<"$task_output" | grep -oE '[0-9]+' || true)"

if [ -z "$task_id" ]; then
  echo "Could not determine migration task ID" >&2
  exit 1
fi

wait_for_task "$migration_app" "$task_id"

# Keep the workflow-scoped lock through the worker and web rollout. A failed job
# releases it through the EXIT trap; the web rollout is responsible for release.
trap - EXIT
