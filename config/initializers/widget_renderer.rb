# Load the Rust widget renderer extension
begin
  require_relative '../../ext/widget_renderer/widget_renderer'
rescue LoadError => e
  Rails.logger.warn "Widget renderer extension not available: #{e.message}"
  Rails.logger.warn "Falling back to ERB template rendering"
end
