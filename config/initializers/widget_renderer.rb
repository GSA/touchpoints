# Skip widget renderer during migrations or rake tasks (library may not be built yet)
if defined?(Rails::Console) || (defined?(Rails::Server) && Rails.env.production?) || Rails.env.development? || Rails.env.test?
  # Load the Rust widget renderer extension
  begin
    # Try loading the precompiled Rutie extension.
    require_relative '../../ext/widget_renderer/lib/widget_renderer'

    # Verify the class was properly defined
    if defined?(WidgetRenderer) && WidgetRenderer.respond_to?(:generate_js)
      Rails.logger.info "WidgetRenderer: Rust extension loaded successfully! generate_js method available."
    else
      Rails.logger.warn "WidgetRenderer: Class defined but generate_js method not available."
      Rails.logger.warn "WidgetRenderer: defined?(WidgetRenderer) = #{defined?(WidgetRenderer)}"
      Rails.logger.warn "WidgetRenderer: respond_to?(:generate_js) = #{WidgetRenderer.respond_to?(:generate_js) rescue 'N/A'}"
    end
  rescue LoadError => e
    Rails.logger.warn "Widget renderer native library not available: #{e.message}"
    Rails.logger.warn 'Rust extension must be built during staging; falling back to ERB template rendering.'
  rescue SystemExit => e
    Rails.logger.error "Widget renderer exited during load: #{e.message}"
    Rails.logger.warn 'Falling back to ERB template rendering'
  rescue StandardError => e
    Rails.logger.error "Widget renderer failed to load: #{e.class}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n") if e.backtrace
    Rails.logger.warn 'Falling back to ERB template rendering'
  end
else
  Rails.logger.info "WidgetRenderer: Skipping load during rake task/migration (library may not be built yet)"
end
