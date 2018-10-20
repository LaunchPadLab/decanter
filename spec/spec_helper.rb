# frozen_string_literal: true

# Report Coverage to Code Climate
require 'simplecov'
SimpleCov.start do
  add_filter '/.rv/'
  add_filter '/spec/'
end


$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'decanter'
