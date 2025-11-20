# frozen_string_literal: true

require 'rutie'

module WidgetRenderer
  root = File.expand_path('..', __dir__)

  # Attempt to find the library path
  # Standard structure: root/target/release
  if File.directory?(File.join(root, 'target', 'release'))
    path = File.join(root, 'target', 'release')
  # Fallback if root is one level up (e.g. ext/)
  elsif File.directory?(File.join(root, 'widget_renderer', 'target', 'release'))
    path = File.join(root, 'widget_renderer', 'target', 'release')
  else
    path = root
  end

  Rutie.new(:widget_renderer).init 'Init_widget_renderer', path
end
