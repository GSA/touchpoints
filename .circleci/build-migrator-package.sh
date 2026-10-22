#!/usr/bin/env bash

set -euo pipefail

package_dir="tmp/cf-migrator"

rm -rf "$package_dir"
mkdir -p "$package_dir/.bundle" "$package_dir/bin" "$package_dir/db/migrate"

cp Gemfile Gemfile.lock "$package_dir/"
cp bin/standalone-migrate "$package_dir/bin/standalone-migrate"
cp db/migrate/*.rb "$package_dir/db/migrate/"

cat > "$package_dir/.bundle/config" <<'YAML'
---
BUNDLE_DEPLOYMENT: "true"
BUNDLE_ONLY: "migrator"
YAML

chmod +x "$package_dir/bin/standalone-migrate"

migration_count="$(find "$package_dir/db/migrate" -name '*.rb' -type f | wc -l | tr -d ' ')"
echo "Built migrator package at $package_dir with $migration_count migration file(s)"
