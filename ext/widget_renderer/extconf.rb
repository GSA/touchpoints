require 'mkmf'

unless system('which rustc > /dev/null 2>&1')
  abort "Rust compiler not found. Please install Rust."
end

system('cargo build --release') or abort "Failed to build Rust extension"

$LDFLAGS += " -L#{Dir.pwd}/target/release -lwidget_renderer"
create_makefile('widget_renderer')
