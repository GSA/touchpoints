#!/usr/bin/env bash

set -euo pipefail

require_env() {
  local var_name="$1"
  if [ -z "${!var_name:-}" ]; then
    echo "Missing required env var: ${var_name}" >&2
    exit 1
  fi
}

escape_private_key() {
  ruby -e 'print STDIN.read.gsub("\r\n", "\n").gsub("\n", "\\n")'
}

sync_login_gov_env() {
  local app_name="$1"

  require_env LOGIN_GOV_CLIENT_ID
  require_env LOGIN_GOV_IDP_BASE_URL
  require_env LOGIN_GOV_REDIRECT_URI
  require_env LOGIN_GOV_PRIVATE_KEY

  local private_key_escaped
  private_key_escaped="$(printf "%s" "${LOGIN_GOV_PRIVATE_KEY}" | escape_private_key)"

  cf set-env "$app_name" LOGIN_GOV_CLIENT_ID "$LOGIN_GOV_CLIENT_ID" >/dev/null
  cf set-env "$app_name" LOGIN_GOV_IDP_BASE_URL "$LOGIN_GOV_IDP_BASE_URL" >/dev/null
  cf set-env "$app_name" LOGIN_GOV_REDIRECT_URI "$LOGIN_GOV_REDIRECT_URI" >/dev/null
  cf set-env "$app_name" LOGIN_GOV_PRIVATE_KEY "$private_key_escaped" >/dev/null

  echo "Synced Login.gov env to ${app_name}"
}

if [ "${1:-}" == "" ]; then
  echo "Usage: $0 <app-name>" >&2
  exit 2
fi

sync_login_gov_env "$1"

