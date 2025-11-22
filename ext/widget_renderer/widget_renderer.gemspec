# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'widget_renderer'
  spec.version       = '0.1.1'
  spec.authors       = ['GSA']
  spec.email         = ['touchpoints@gsa.gov']

  spec.summary       = 'Rust-based widget renderer for Touchpoints'
  spec.description   = 'A Rutie-based Rust extension for rendering widgets.'
  spec.homepage      = 'https://github.com/GSA/touchpoints'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files         = Dir['{src,lib}/**/*', 'Cargo.toml', 'Cargo.lock', 'extconf.rb']
  spec.extensions    = ['extconf.rb']
  spec.require_paths = ['lib']

  spec.add_dependency 'fiddle'
  spec.add_dependency 'rutie'
end
