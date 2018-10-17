# frozen_string_literal: true

require 'rails'
require 'action_controller/railtie'
require 'rspec/rails'
require 'spec_helper'

ENV['RAILS_ENV'] = 'test'

class RailsApp < Rails::Application
  # secret_key_base needed to let rails 4.2 work
  config.secret_key_base = 'test' * 15
  # eager_load = false shuts up a warning
  config.eager_load = false
end

RailsApp.initialize!
