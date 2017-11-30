# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'decanter/version'

Gem::Specification.new do |spec|
  spec.name          = 'decanter'
  spec.version       = Decanter::VERSION
  spec.authors       = ['Ryan Francis', 'David Corwin']
  spec.email         = ['ryan@launchpadlab.com']

  spec.summary       = %q{Form Parser for Rails}
  spec.description   = %q{Decanter aims to reduce complexity in Rails controllers by creating a place for transforming data before it hits the model and database.}
  spec.homepage      = 'https://github.com/launchpadlab/decanter'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'actionpack', '~> 4.2.10'

  spec.add_development_dependency 'simplecov', '~> 0.15.1'
  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'dotenv'
  spec.add_development_dependency 'pry'
end
