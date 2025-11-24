# Load the Rust widget renderer extension
begin
  # Try loading the precompiled Rutie extension.
  require_relative '../../ext/widget_renderer/lib/widget_renderer'
rescue LoadError => e
  Rails.logger.warn "Widget renderer native library not available: #{e.message}"
  Rails.logger.warn 'Rust extension must be built during staging; falling back to ERB template rendering.'
rescue StandardError => e
  Rails.logger.error "Widget renderer failed to load: #{e.class}: #{e.message}"
  Rails.logger.error e.backtrace.join("\n") if e.backtrace
  Rails.logger.warn 'Falling back to ERB template rendering'
end
