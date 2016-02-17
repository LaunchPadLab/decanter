$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'decanter'
require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start
