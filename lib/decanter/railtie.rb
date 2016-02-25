require 'decanter'

class Decanter::Railtie < Rails::Railtie

  initializer 'decanter.active_record' do
    ActiveSupport.on_load :active_record do
      require 'decanter/extensions'
      Decanter::Extensions::ActiveRecord.enable!
    end
  end

  # initializer 'decanter.load' do |app|
  #   ActiveSupport.on_load :decanter do
  #     Dir[ File.expand_path(Rails.root.join("app/decanter/**/*.rb")) ].each do |file|
  #       require file
  #     end
  #   end
  # end

  config.to_prepare do
    Dir[ File.expand_path(Rails.root.join("app/decanter/**/*.rb")) ].each do |file|
      require file
    end
  end

  generators do |app|
    Rails::Generators.configure!(app.config.generators)
    Rails::Generators.hidden_namespaces.uniq!
    require 'generators/rails/resource_override'
  end
end
