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
LIB_TARGET="${EXT_DIR}/target/release/libwidget_renderer.so"

echo "===> widget_renderer: checking for native library in ${EXT_DIR}"

# Function to check if library has correct linkage (libruby.so resolves)
check_library_linkage() {
  local lib_path="$1"
  if [ ! -f "$lib_path" ]; then
    return 1
  fi
  # Check if ldd shows "libruby.so.3.2 => not found"
  if ldd "$lib_path" 2>&1 | grep -q "libruby.*not found"; then
    echo "===> widget_renderer: Library at $lib_path has broken linkage (libruby not found)"
    return 1
  fi
  return 0
}

# Function to build the Rust extension
build_rust_extension() {
  echo "===> widget_renderer: Building native extension with Cargo"

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
    return 1
  fi

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
  
  # Clean old build artifacts that may have wrong linkage
  rm -rf target/release/libwidget_renderer.so 2>/dev/null || true
  rm -f libwidget_renderer.so 2>/dev/null || true
  
  # Build with Cargo
  "$CARGO_BIN" build --release 2>&1
  
  if [ -f "target/release/libwidget_renderer.so" ]; then
    cp target/release/libwidget_renderer.so .
    echo "===> widget_renderer: Successfully built native extension"
    echo "===> widget_renderer: Library dependencies:"
    ldd target/release/libwidget_renderer.so 2>&1 || true
    return 0
  else
    echo "===> widget_renderer: ERROR - Build failed, library not found"
    ls -la target/release/ 2>&1 || true
    return 1
  fi
}

# Check if we have a library with correct linkage
NEED_BUILD=false

if [ -f "$LIB_TARGET" ]; then
  echo "===> widget_renderer: Found library at $LIB_TARGET"
  if check_library_linkage "$LIB_TARGET"; then
    echo "===> widget_renderer: Library linkage OK, copying to expected location"
    cp "$LIB_TARGET" "$LIB_SO" 2>/dev/null || true
  else
    echo "===> widget_renderer: Library has broken linkage, will rebuild"
    NEED_BUILD=true
  fi
elif [ -f "$LIB_SO" ]; then
  echo "===> widget_renderer: Found library at $LIB_SO"
  if check_library_linkage "$LIB_SO"; then
    echo "===> widget_renderer: Library linkage OK"
  else
    echo "===> widget_renderer: Library has broken linkage, will rebuild"
    NEED_BUILD=true
  fi
else
  echo "===> widget_renderer: No library found, will build"
  NEED_BUILD=true
fi

# Build if needed
if [ "$NEED_BUILD" = true ]; then
  build_rust_extension
fi

echo "===> widget_renderer: Setup complete"
