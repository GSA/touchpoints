#!/usr/bin/env bash
# We want failures in optional copy steps to fall through to the build step,
# not kill the process before Rails boots.
set -uo pipefail

# CRITICAL: Set LD_LIBRARY_PATH so the Rust extension can find libruby.so at runtime
# The Ruby buildpack installs Ruby under /home/vcap/deps/*/ruby/lib/

# First, try to find Ruby's libdir using ruby itself (most reliable)
if command -v ruby >/dev/null 2>&1; then
    RUBY_LIB_DIR=$(ruby -e 'require "rbconfig"; print RbConfig::CONFIG["libdir"]' 2>/dev/null || true)
    if [ -n "$RUBY_LIB_DIR" ] && [ -d "$RUBY_LIB_DIR" ]; then
        export LD_LIBRARY_PATH="${RUBY_LIB_DIR}:${LD_LIBRARY_PATH:-}"
        echo "===> widget_renderer: Added Ruby libdir ${RUBY_LIB_DIR} to LD_LIBRARY_PATH"
    fi
fi

# Also scan deps directories as a fallback
for dep_dir in /home/vcap/deps/*/; do
    # Check for Ruby library directory
    if [ -d "${dep_dir}ruby/lib" ]; then
        if [ -f "${dep_dir}ruby/lib/libruby.so.3.2" ] || [ -f "${dep_dir}ruby/lib/libruby.so" ]; then
            export LD_LIBRARY_PATH="${dep_dir}ruby/lib:${LD_LIBRARY_PATH:-}"
            echo "===> widget_renderer: Added ${dep_dir}ruby/lib to LD_LIBRARY_PATH"
        fi
    fi
done

# Make sure LD_LIBRARY_PATH is exported for the app process
echo "===> widget_renderer: Final LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}"

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
    cp "$src" "${EXT_DIR}/target/release/libwidget_renderer.so" 2>/dev/null || true
    cp "$src" "${EXT_DIR}/libwidget_renderer.so" 2>/dev/null || true
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

  # Find the Rust installation from the Rust buildpack
  CARGO_BIN=""
  for dep_dir in /home/vcap/deps/*/; do
    if [ -x "${dep_dir}rust/cargo/bin/cargo" ]; then
      CARGO_BIN="${dep_dir}rust/cargo/bin/cargo"
      export CARGO_HOME="${dep_dir}rust/cargo"
      export RUSTUP_HOME="${dep_dir}rust/rustup"
      export PATH="${dep_dir}rust/cargo/bin:$PATH"
      break
    fi
  done

  if [ -z "$CARGO_BIN" ]; then
    echo "===> widget_renderer: ERROR - Cargo not found in deps"
    echo "===> widget_renderer: Skipping build - app will fail if Rust extension is required"
    # Don't exit - let the app try to start and fail with a clear error
  else
    echo "===> widget_renderer: Using cargo at $CARGO_BIN"
    echo "===> widget_renderer: CARGO_HOME=${CARGO_HOME:-unset}"
    echo "===> widget_renderer: RUSTUP_HOME=${RUSTUP_HOME:-unset}"

    # Tell rutie to link against the shared Ruby library provided by the Ruby buildpack.
    RUBY_LIB_PATH=$(ruby -e 'require "rbconfig"; print RbConfig::CONFIG["libdir"]')
    RUBY_SO_NAME=$(ruby -e 'require "rbconfig"; print RbConfig::CONFIG["RUBY_SO_NAME"]')
    export RUTIE_RUBY_LIB_PATH="$RUBY_LIB_PATH"
    export RUTIE_RUBY_LIB_NAME="$RUBY_SO_NAME"
    unset RUBY_STATIC
    export NO_LINK_RUTIE=1

    echo "===> widget_renderer: Building with RUTIE_RUBY_LIB_PATH=$RUBY_LIB_PATH"

    cd "$EXT_DIR"
    
    # Build with Cargo
    "$CARGO_BIN" build --release 2>&1
    
    if [ -f "target/release/libwidget_renderer.so" ]; then
      cp target/release/libwidget_renderer.so .
      echo "===> widget_renderer: Successfully built native extension"
      echo "===> widget_renderer: Library dependencies:"
      ldd target/release/libwidget_renderer.so 2>&1 || true
    else
      echo "===> widget_renderer: ERROR - Build failed, library not found"
      ls -la target/release/ 2>&1 || true
    fi
  fi
else
  echo "===> widget_renderer: native extension already present"
fi
