#!/usr/bin/env bash
set -euo pipefail

if [ -d "${HOME}/ext/widget_renderer" ]; then
  EXT_DIR="${HOME}/ext/widget_renderer"
elif [ -d "${HOME}/app/ext/widget_renderer" ]; then
  EXT_DIR="${HOME}/app/ext/widget_renderer"
else
  echo "===> widget_renderer: extension directory not found under HOME: ${HOME}"
  exit 1
fi
LIB_SO="${EXT_DIR}/libwidget_renderer.so"
LIB_DYLIB="${EXT_DIR}/libwidget_renderer.dylib"

echo "===> widget_renderer: checking for native library"

# Build the Rust extension at runtime if the shared library is missing.
if [ ! -f "$LIB_SO" ] && [ ! -f "$LIB_DYLIB" ]; then
  echo "===> widget_renderer: building native extension"
  cd "$EXT_DIR"
  ruby extconf.rb
  make
else
  echo "===> widget_renderer: native extension already present"
fi
