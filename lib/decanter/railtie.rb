require 'rails'
require_relative 'extensions'

class Decanter::Railtie < Rails::Railtie

  initializer 'decanter.configure' do
    ActiveRecord::Base.include(Decanter::Extensions) if defined? ActiveRecord
  end
end
