#!/usr/bin/env bash
set -uo pipefail

# 1. Set LD_LIBRARY_PATH so the Rust extension can find libruby.so
if command -v ruby >/dev/null 2>&1; then
    RUBY_LIB_DIR=$(ruby -e 'require "rbconfig"; print RbConfig::CONFIG["libdir"]' 2>/dev/null || true)
    if [ -n "$RUBY_LIB_DIR" ] && [ -d "$RUBY_LIB_DIR" ]; then
        export LD_LIBRARY_PATH="${RUBY_LIB_DIR}:${LD_LIBRARY_PATH:-}"
    fi
fi

# 2. Locate the extension directory
if [ -d "${HOME}/app/ext/widget_renderer" ]; then
  EXT_DIR="${HOME}/app/ext/widget_renderer"
else
  EXT_DIR="${HOME}/ext/widget_renderer"
fi

# 3. Copy the pre-built library from the target directory to the extension directory
# The Rust buildpack puts compiled artifacts in /home/vcap/app/target/release/
STRATEGIC_LIB="/home/vcap/app/target/release/libwidget_renderer.so"
DEST_LIB="${EXT_DIR}/libwidget_renderer.so"

if [ -f "$STRATEGIC_LIB" ]; then
  echo "===> widget_renderer: Copying pre-built library to ${DEST_LIB}"
  cp "$STRATEGIC_LIB" "$DEST_LIB"
elif [ -f "${EXT_DIR}/target/release/libwidget_renderer.so" ]; then
  echo "===> widget_renderer: Copying local-built library to ${DEST_LIB}"
  cp "${EXT_DIR}/target/release/libwidget_renderer.so" "$DEST_LIB"
fi

echo "===> widget_renderer: Setup complete. LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}"
