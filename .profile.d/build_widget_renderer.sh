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

# 3. Build the Rust library if it doesn't exist
DEST_LIB="${EXT_DIR}/libwidget_renderer.so"

if [ ! -f "$DEST_LIB" ]; then
  echo "===> widget_renderer: Building Rust library..."
  cd "$EXT_DIR"
  
  # Clean any stale artifacts
  rm -rf target/release/libwidget_renderer.so 2>/dev/null || true
  
  # Build the library
  cargo build --release
  
  if [ -f "target/release/libwidget_renderer.so" ]; then
    cp "target/release/libwidget_renderer.so" "$DEST_LIB"
    echo "===> widget_renderer: Successfully built and installed library"
  else
    echo "===> widget_renderer: ERROR - Failed to build library"
    exit 1
  fi
else
  echo "===> widget_renderer: Library already exists at ${DEST_LIB}"
fi

echo "===> widget_renderer: Setup complete. LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}"
