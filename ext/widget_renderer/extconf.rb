require 'mkmf'

abort 'Rust compiler not found. Please install Rust.' unless system('which rustc > /dev/null 2>&1')

system('cargo build --release') or abort 'Failed to build Rust extension'

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
