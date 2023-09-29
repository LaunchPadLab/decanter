require 'rails/generators'
require 'rails/generators/rails/resource/resource_generator'

module Rails
  module Generators
    class ResourceGenerator
      puts 'RUNNING RESOURCE OVERRIDE IN LOCAL REPO'
      hook_for :decanter, default: true, type: :boolean
    end
  end
end
