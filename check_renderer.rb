begin
  require_relative 'ext/widget_renderer/widget_renderer'
  puts 'WidgetRenderer loaded successfully'
  puts "WidgetRenderer defined: #{defined?(WidgetRenderer)}"
rescue LoadError => e
  puts "Failed to load WidgetRenderer: #{e.message}"
end
