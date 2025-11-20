# frozen_string_literal: true

require 'rutie'

module WidgetRenderer
  root = File.expand_path('..', __dir__)
  
  # Define potential paths where the shared object might be located
  paths = [
    File.join(root, 'target', 'release'),
    File.join(root, 'widget_renderer', 'target', 'release'),
    File.join(root, 'target', 'debug'),
    File.join(root, 'widget_renderer', 'target', 'debug'),
    root
  ]
  
  # Find the first path that contains the library file
  found_path = paths.find do |p|
    File.exist?(File.join(p, 'libwidget_renderer.so')) ||
    File.exist?(File.join(p, 'libwidget_renderer.bundle')) ||
    File.exist?(File.join(p, 'libwidget_renderer.dylib'))
  end
  
  # Default to root if not found (Rutie might have its own lookup)
  path = found_path || root

  Rutie.new(:widget_renderer).init 'Init_widget_renderer', path
end
