require 'rails'
require_relative 'extensions'

class Decanter::Railtie < Rails::Railtie

  initializer 'decanter.configure' do
    ActiveRecord::Base.include(Decanter::Extensions) if defined? ActiveRecord
  end

  generators do |app|
    Rails::Generators.configure!(app.config.generators)
    Rails::Generators.hidden_namespaces.uniq!
    require 'generators/rails/resource_override'
  end
end
