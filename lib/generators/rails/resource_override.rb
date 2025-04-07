# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/rails/resource/resource_generator'

module Rails
  module Generators
    class ResourceGenerator
      hook_for :decanter, default: true, type: :boolean
    end
  end
end
