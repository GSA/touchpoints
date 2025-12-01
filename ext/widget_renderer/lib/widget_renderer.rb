# frozen_string_literal: true

require 'rutie'
require 'fileutils'

root = File.expand_path('..', __dir__)

# Debugging: Print root and directory contents
puts "WidgetRenderer: root=#{root}"
puts "WidgetRenderer: __dir__=#{__dir__}"

# If a stale module exists, remove it so Rutie can define or reopen the class.
if defined?(WidgetRenderer) && WidgetRenderer.is_a?(Module) && !WidgetRenderer.is_a?(Class)
  Object.send(:remove_const, :WidgetRenderer)
end
# Ensure the constant exists as a Class so rb_define_class will reopen it instead of erroring on Module.
WidgetRenderer = Class.new unless defined?(WidgetRenderer) && WidgetRenderer.is_a?(Class)

# Check for library file extensions based on platform
lib_extensions = %w[.so .bundle .dylib]
lib_names = lib_extensions.map { |ext| "libwidget_renderer#{ext}" }

# Define potential paths where the shared object might be located
paths = [
  File.join(root, 'target', 'release'),
  File.expand_path('../../target/release', root), # Workspace target directory
  File.join(root, 'widget_renderer', 'target', 'release'),
  File.join(root, 'target', 'debug'),
  File.expand_path('../../target/debug', root), # Workspace debug directory
  File.join(root, 'widget_renderer', 'target', 'debug'),
  root,
]

# Find the first path that contains the library file
found_path = nil
found_lib = nil
paths.each do |p|
  lib_names.each do |lib_name|
    full_path = File.join(p, lib_name)
    exists = File.exist?(full_path)
    puts "WidgetRenderer: Checking #{full_path} -> #{exists}"
    if exists
      found_path = p
      found_lib = full_path
      break
    end
  end
  break if found_path
end

if found_path
  puts "WidgetRenderer: Found library in #{found_path}"
  
  # Debug: Check dependencies
  if File.exist?(found_lib)
    puts "WidgetRenderer: File details for #{found_lib}"
    puts `ls -l #{found_lib}`
    puts `file #{found_lib}`
    puts "WidgetRenderer: Running ldd on #{found_lib}"
    puts `ldd #{found_lib} 2>&1`
  end
  
  # Rutie always looks for the library in <root>/target/release/libwidget_renderer.so
  # If the library is not in that exact location, copy/symlink it there
  expected_target_release = File.join(root, 'target', 'release')
  expected_lib = File.join(expected_target_release, File.basename(found_lib))
  
  unless File.exist?(expected_lib)
    puts "WidgetRenderer: Library not in expected location, copying to #{expected_lib}"
    FileUtils.mkdir_p(expected_target_release)
    
    # Copy or symlink the library to the expected location
    begin
      FileUtils.cp(found_lib, expected_lib)
      puts "WidgetRenderer: Copied library to #{expected_lib}"
    rescue => e
      puts "WidgetRenderer: Failed to copy library: #{e.message}"
      # Try symlink as fallback
      begin
        File.symlink(found_lib, expected_lib)
        puts "WidgetRenderer: Created symlink at #{expected_lib}"
      rescue => e2
        puts "WidgetRenderer: Failed to create symlink: #{e2.message}"
      end
    end
  end
else
  puts 'WidgetRenderer: Library not found in any checked path. Listing root contents:'
  # List files in root to help debug
  Dir.glob(File.join(root, '*')).each { |f| puts f }
  
  puts 'WidgetRenderer: Listing target contents:'
  target_dir = File.join(root, 'target')
  if Dir.exist?(target_dir)
    Dir.glob(File.join(target_dir, '*')).each { |f| puts f }
  else
    puts "WidgetRenderer: target directory does not exist at #{target_dir}"
  end

  puts 'WidgetRenderer: Listing target/release contents:'
  release_dir = File.join(root, 'target', 'release')
  if Dir.exist?(release_dir)
    Dir.glob(File.join(release_dir, '*')).each { |f| puts f }
  else
    puts "WidgetRenderer: target/release directory does not exist at #{release_dir}"
  end
end

# Rutie expects the project root and appends /target/release/lib<name>.so
# Pass the root directory with 'lib' appended (Rutie goes up one level)
path = File.join(root, 'lib')

puts "WidgetRenderer: Initializing Rutie with path: #{path}"

Rutie.new(:widget_renderer).init 'Init_widget_renderer', path
