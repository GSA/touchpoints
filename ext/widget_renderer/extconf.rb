require 'mkmf'
require 'fileutils'

def ensure_rust
  cargo_home = ENV['CARGO_HOME']
  rustup_home = ENV['RUSTUP_HOME']

  if cargo_home.nil? || cargo_home.empty?
    root = File.expand_path(File.join(__dir__, '..', '.rust'))
    cargo_home = File.join(root, 'cargo')
    rustup_home = File.join(root, 'rustup')
    ENV['CARGO_HOME'] = cargo_home
    ENV['RUSTUP_HOME'] = rustup_home
  end

  cargo_bin = File.join(cargo_home, 'bin', 'cargo')

  unless File.executable?(cargo_bin)
    puts 'Rust toolchain not found. Installing via rustup...'
    system('curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal') or abort 'Failed to install Rust via rustup'
  end

  # Make cargo available for the build step without clobbering PATH
  ENV['PATH'] = "#{File.join(cargo_home, 'bin')}:#{ENV.fetch('PATH', '')}"

  cargo_bin
end

cargo_bin = ensure_rust

puts "Current directory: #{Dir.pwd}"
puts "Using cargo executable: #{cargo_bin}"
system("#{cargo_bin} build --release") or abort 'Failed to build Rust extension'

# Copy the built shared library into the extension root so it is included in the droplet.
# Dir.glob does not expand `{}` patterns, so search explicitly for common extensions.
candidates = %w[so dylib dll].flat_map do |ext|
  [
    File.join('target', 'release', "libwidget_renderer.#{ext}"),
    File.join('..', '..', 'target', 'release', "libwidget_renderer.#{ext}") # workspace target
  ]
end

built_lib = candidates.find { |path| File.file?(path) }
abort 'Built library not found after cargo build' unless built_lib

dest_root = File.join(Dir.pwd, File.basename(built_lib))
dest_release_dir = File.join(Dir.pwd, 'target', 'release')
FileUtils.mkdir_p(dest_release_dir)

FileUtils.cp(built_lib, dest_root)
FileUtils.cp(built_lib, dest_release_dir)

puts "Copied built library to #{dest_root} and #{dest_release_dir}"

# Debug: Check build artifacts
puts "Listing target directory:"
system('ls -R target')

# Debug: Check dependencies of the generated library
puts "Checking dependencies of libwidget_renderer.so..."
system('ldd target/release/libwidget_renderer.so')
puts "End of dependencies check."

# Check for the library in the local target directory or the workspace target directory
local_target = File.join(Dir.pwd, 'target', 'release')
workspace_target = File.expand_path('../../target/release', Dir.pwd)

lib_dir = if %w[so dylib dll].any? { |ext| File.exist?(File.join(local_target, "libwidget_renderer.#{ext}")) }
            local_target
          elsif %w[so dylib dll].any? { |ext| File.exist?(File.join(workspace_target, "libwidget_renderer.#{ext}")) }
            workspace_target
          else
            local_target # Fallback
          end

$LDFLAGS += " -L#{lib_dir} -lwidget_renderer"
create_makefile('widget_renderer')
