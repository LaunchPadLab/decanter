# Report Coverage to Code Climate
ENV["CODECLIMATE_REPO_TOKEN"] = 'bd0e4ddfc3803eff195d192c403c65070061221b3d0dd4678939744ae49ddc29'
require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'decanter'

# Code Coverage
# require 'simplecov'
# SimpleCov.start


