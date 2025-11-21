require 'mkmf'

cargo_home = ENV['CARGO_HOME']
cargo_bin = if cargo_home && !cargo_home.empty?
              File.join(cargo_home, 'bin', 'cargo')
            else
              'cargo'
            end

abort 'Rust compiler not found. Please install Rust.' unless File.executable?(cargo_bin) || system('which rustc >/dev/null 2>&1')

puts "Current directory: #{Dir.pwd}"
puts "Using cargo executable: #{cargo_bin}"
system("#{cargo_bin} build --release") or abort 'Failed to build Rust extension'

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

lib_dir = if Dir.glob(File.join(local_target, 'libwidget_renderer.{so,dylib,dll}')).any?
            local_target
          elsif Dir.glob(File.join(workspace_target, 'libwidget_renderer.{so,dylib,dll}')).any?
            workspace_target
          else
            local_target # Fallback
          end

$LDFLAGS += " -L#{lib_dir} -lwidget_renderer"
create_makefile('widget_renderer')
