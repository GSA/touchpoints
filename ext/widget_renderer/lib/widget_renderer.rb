# frozen_string_literal: true

require 'rutie'

module WidgetRenderer
  root = File.expand_path('..', __dir__)
  
  # Debugging: Print root and directory contents
  puts "WidgetRenderer: root=#{root}"
  puts "WidgetRenderer: __dir__=#{__dir__}"
  
  # Define potential paths where the shared object might be located
  paths = [
    File.join(root, 'target', 'release'),
    File.expand_path('../../target/release', root), # Workspace target directory
    File.join(root, 'widget_renderer', 'target', 'release'),
    File.join(root, 'target', 'debug'),
    File.expand_path('../../target/debug', root), # Workspace debug directory
    File.join(root, 'widget_renderer', 'target', 'debug'),
    root
  ]
  
  # Find the first path that contains the library file
  found_path = paths.find do |p|
    exists = File.exist?(File.join(p, 'libwidget_renderer.so')) ||
             File.exist?(File.join(p, 'libwidget_renderer.bundle')) ||
             File.exist?(File.join(p, 'libwidget_renderer.dylib'))
    puts "WidgetRenderer: Checking #{p} -> #{exists}"
    exists
  end
  
  if found_path
    puts "WidgetRenderer: Found library in #{found_path}"
  else
    puts "WidgetRenderer: Library not found in any checked path. Listing root contents:"
    # List files in root to help debug
    Dir.glob(File.join(root, '**', '*')).each { |f| puts f }
  end

  # Default to root if not found (Rutie might have its own lookup)
  path = found_path || root

  # Rutie expects the project root, not the directory containing the library.
  # It appends /target/release/lib<name>.so to the path.
  # So if we found it in .../target/release, we need to strip that part.
  if path.end_with?('target/release')
    path = path.sub(%r{/target/release$}, '')
  elsif path.end_with?('target/debug')
    path = path.sub(%r{/target/debug$}, '')
  end

  # Rutie assumes the passed path is a subdirectory (like lib/) and goes up one level
  # before appending target/release.
  # So we append a 'lib' directory so that when it goes up, it lands on the root.
  path = File.join(path, 'lib')

  puts "WidgetRenderer: Initializing Rutie with path: #{path}"

  Rutie.new(:widget_renderer).init 'Init_widget_renderer', path
end
