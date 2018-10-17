require 'decanter'

class Decanter::Railtie < Rails::Railtie
  initializer 'decanter.active_record' do
    ActiveSupport.on_load :active_record do
      require 'decanter/extensions'
      Decanter::Extensions::ActiveRecordExtensions.enable!
    end
  end

  initializer 'decanter.parser.autoload', before: :set_autoload_paths do |app|
    app.config.autoload_paths << Rails.root.join('lib/decanter/parsers')
  end

  generators do |app|
    Rails::Generators.configure!(app.config.generators)
    Rails::Generators.hidden_namespaces.uniq!
    require 'generators/rails/resource_override'
  end
end
