require 'decanter'

class Decanter::Railtie < Rails::Railtie

  initializer 'decanter.active_record' do
    ActiveSupport.on_load :active_record do
      require 'decanter/extensions'
      Decanter::Extensions::ActiveRecord.enable!
    end
  end

  generators do |app|
    Rails::Generators.configure!(app.config.generators)
    Rails::Generators.hidden_namespaces.uniq!
    require 'generators/rails/resource_override'
  end
end
