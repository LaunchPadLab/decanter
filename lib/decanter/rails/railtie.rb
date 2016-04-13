require 'decanter'

class Decanter::Rails::Railtie < Rails::Railtie

  initializer 'decanter.active_record' do
    ActiveSupport.on_load :active_record do
      require 'decanter/extensions'
      Decanter::Extensions::ActiveRecord.enable!
    end
  end

  config.to_prepare do
    Dir[
      File.expand_path(Rails.root.join("lib/decanter/parsers/*"))
    ].each { |file| require file }
  end

  generators do |app|
    Rails::Generators.configure!(app.config.generators)
    Rails::Generators.hidden_namespaces.uniq!
    require 'generators/rails/resource_override'
  end
end
