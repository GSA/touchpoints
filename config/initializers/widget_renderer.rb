# Load the Rust widget renderer extension
begin
  # Try loading from the extension directory
  require_relative '../../ext/widget_renderer/widget_renderer'
rescue LoadError => e
  Rails.logger.warn "Widget renderer extension not available: #{e.message}"
  Rails.logger.warn 'Falling back to ERB template rendering'
  puts "Widget renderer extension not available: #{e.message}" if Rails.env.test?
end
