#!/usr/bin/env bash
# We want failures in optional copy steps to fall through to the build step,
# not kill the process before Rails boots.
set -uo pipefail

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

echo "===> widget_renderer: checking for native library in ${EXT_DIR}"

# Helper: hydrate from a built library if it already exists.
copy_lib() {
  local src="$1"
  if [ -f "$src" ]; then
    echo "===> widget_renderer: using prebuilt library at $src"
    mkdir -p "${EXT_DIR}/target/release"
    cp "$src" "${EXT_DIR}/target/release/libwidget_renderer.so"
    cp "$src" "${EXT_DIR}/libwidget_renderer.so"
    return 0
  else
    echo "===> widget_renderer: no library at $src"
  fi
  return 1
}

# Try common build locations before attempting to compile. Do not exit early if they are absent.
set +e
copy_lib "${EXT_DIR}/target/release/libwidget_renderer.so" || \
copy_lib "${HOME}/target/release/libwidget_renderer.so" || \
copy_lib "${HOME}/app/target/release/libwidget_renderer.so" || \
copy_lib "${HOME}/app/ext/widget_renderer/libwidget_renderer.so"
copy_status=$?
set -e

# Build the Rust extension at runtime if the shared library is missing.
if [ ! -f "$LIB_SO" ] && [ ! -f "$LIB_DYLIB" ]; then
  echo "===> widget_renderer: building native extension"

  # Ensure Cargo toolchain from the Rust buildpack is used (avoid reinstall).
  if [ -z "${CARGO_HOME:-}" ] && [ -d "/home/vcap/deps/0/rust/cargo" ]; then
    export CARGO_HOME="/home/vcap/deps/0/rust/cargo"
  fi
  if [ -z "${RUSTUP_HOME:-}" ] && [ -d "/home/vcap/deps/0/rust/rustup" ]; then
    export RUSTUP_HOME="/home/vcap/deps/0/rust/rustup"
  fi
  echo "===> widget_renderer: CARGO_HOME=${CARGO_HOME:-unset}"
  echo "===> widget_renderer: RUSTUP_HOME=${RUSTUP_HOME:-unset}"

  # Tell rutie to link against the shared Ruby library provided by the Ruby buildpack.
  RUBY_LIB_PATH=$(ruby -e 'require "rbconfig"; print RbConfig::CONFIG["libdir"]')
  RUBY_SO_NAME=$(ruby -e 'require "rbconfig"; print RbConfig::CONFIG["RUBY_SO_NAME"]')
  export RUTIE_RUBY_LIB_PATH="$RUBY_LIB_PATH"
  export RUTIE_RUBY_LIB_NAME="$RUBY_SO_NAME"
  unset RUBY_STATIC
  export NO_LINK_RUTIE=1

  cd "$EXT_DIR"
  ruby extconf.rb
  make
else
  echo "===> widget_renderer: native extension already present"
fi
