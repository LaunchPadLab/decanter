# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'decanter/version'

Gem::Specification.new do |spec|
  spec.name          = 'decanter'
  spec.version       = Decanter::VERSION
  spec.authors       = ['Ryan Francis', 'David Corwin']
  spec.email         = ['ryan@launchpadlab.com']

  spec.summary       = 'Form Parser for Rails'
  spec.description   = 'Decanter aims to reduce complexity in Rails controllers by creating a place for transforming data before it hits the model and database.'
  spec.homepage      = 'https://github.com/launchpadlab/decanter'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = Dir.glob('lib/**/*') + Dir.glob('bin/*')
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'actionpack', '>= 4.2.10'
  spec.add_dependency 'activesupport'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'simplecov'
end
