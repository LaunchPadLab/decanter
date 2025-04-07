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
  spec.required_ruby_version = '>= 3.2.0'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  unless spec.respond_to?(:metadata)
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'actionpack', '>= 7.1.3.2'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'rails', '>= 7.1.3.2'
  spec.add_dependency 'rails-html-sanitizer', '>= 1.0.4'

  spec.add_development_dependency 'bundler', '~> 2.4.22'
  spec.add_development_dependency 'dotenv'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec-rails', '~> 3.9'
  spec.add_development_dependency 'rubocop', '~> 1.59'
  spec.add_development_dependency 'simplecov', '~> 0.15.1'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
