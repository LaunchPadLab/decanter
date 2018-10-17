# frozen_string_literal: true

module Decanter
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc 'Creates a Decanter initializer in your application.'

      def copy_initializer
        copy_file 'initializer.rb', 'config/initializers/decanter.rb'
      end
    end
  end
end
