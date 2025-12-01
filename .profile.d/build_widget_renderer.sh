#!/usr/bin/env bash
# We want failures in optional copy steps to fall through to the build step,
# not kill the process before Rails boots.
set -uo pipefail

# CRITICAL: Set LD_LIBRARY_PATH so the Rust extension can find libruby.so at runtime
# The Ruby buildpack installs Ruby under /home/vcap/deps/*/
for dep_dir in /home/vcap/deps/*/; do
    # Check for Ruby library directory
    if [ -f "${dep_dir}lib/libruby.so.3.2" ] || [ -f "${dep_dir}lib/libruby.so" ]; then
        export LD_LIBRARY_PATH="${dep_dir}lib:${LD_LIBRARY_PATH:-}"
        echo "===> widget_renderer: Added ${dep_dir}lib to LD_LIBRARY_PATH"
        break
    fi
    # Also check vendor_bundle ruby structure
    if [ -d "${dep_dir}vendor_bundle/ruby" ]; then
        RUBY_LIB=$(find "${dep_dir}" -name "libruby.so*" -type f 2>/dev/null | head -1 | xargs dirname 2>/dev/null || true)
        if [ -n "$RUBY_LIB" ] && [ -d "$RUBY_LIB" ]; then
            export LD_LIBRARY_PATH="${RUBY_LIB}:${LD_LIBRARY_PATH:-}"
            echo "===> widget_renderer: Added ${RUBY_LIB} to LD_LIBRARY_PATH"
            break
        fi
    fi
done

# Also try to find Ruby's libdir using ruby itself
if command -v ruby >/dev/null 2>&1; then
    RUBY_LIB_DIR=$(ruby -e 'require "rbconfig"; print RbConfig::CONFIG["libdir"]' 2>/dev/null || true)
    if [ -n "$RUBY_LIB_DIR" ] && [ -d "$RUBY_LIB_DIR" ]; then
        export LD_LIBRARY_PATH="${RUBY_LIB_DIR}:${LD_LIBRARY_PATH:-}"
        echo "===> widget_renderer: Added Ruby libdir ${RUBY_LIB_DIR} to LD_LIBRARY_PATH"
    fi
fi

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
  if [ -d "/home/vcap/deps/0/rust/cargo/bin" ]; then
    export CARGO_HOME="/home/vcap/deps/0/rust/cargo"
  fi
  if [ -d "/home/vcap/deps/0/rust/rustup" ]; then
    export RUSTUP_HOME="/home/vcap/deps/0/rust/rustup"
  fi
  # Cargo requires HOME to match the runtime user’s home dir (/home/vcap), not /home/vcap/app.
  export HOME="/home/vcap"
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
