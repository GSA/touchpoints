#!/usr/bin/env bash
set -euo pipefail

APP_ROOT="${HOME}/app"
EXT_DIR="${APP_ROOT}/ext/widget_renderer"
LIB_SO="${EXT_DIR}/libwidget_renderer.so"
LIB_DYLIB="${EXT_DIR}/libwidget_renderer.dylib"

# Build the Rust extension at runtime if the shared library is missing.
if [ ! -f "$LIB_SO" ] && [ ! -f "$LIB_DYLIB" ]; then
  echo "===> widget_renderer: building native extension"
  cd "$EXT_DIR"
  ruby extconf.rb
  make
else
  echo "===> widget_renderer: native extension already present"
fi
