require 'dotenv'
Dotenv.load
# Report Coverage to Code Climate
require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'decanter'
