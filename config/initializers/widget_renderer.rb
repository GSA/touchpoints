# Load the Rust widget renderer extension
begin
  # Try loading from the extension directory
  require_relative '../../ext/widget_renderer/lib/widget_renderer'
rescue LoadError => e
  Rails.logger.warn "Widget renderer extension not available: #{e.message}"
  # Attempt to build the Rust extension on the fly (installs Rust via extconf if needed)
  begin
    Rails.logger.info 'Attempting to compile widget_renderer extension...'
    ext_dir = Rails.root.join('ext', 'widget_renderer')
    Dir.chdir(ext_dir) do
      system('ruby extconf.rb') && system('make')
    end
    require_relative '../../ext/widget_renderer/lib/widget_renderer'
    Rails.logger.info 'Successfully compiled widget_renderer extension at runtime.'
  rescue StandardError => build_error
    Rails.logger.warn "Widget renderer build failed: #{build_error.class}: #{build_error.message}"
    Rails.logger.warn 'Falling back to ERB template rendering'
    puts "Widget renderer build failed: #{build_error.message}" if Rails.env.test?
  end
rescue StandardError => e
  Rails.logger.error "Widget renderer failed to load: #{e.class}: #{e.message}"
  Rails.logger.error e.backtrace.join("\n") if e.backtrace
  Rails.logger.warn 'Falling back to ERB template rendering'
end
