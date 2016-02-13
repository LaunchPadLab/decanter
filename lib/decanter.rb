module Decanter

  @@decanters = {}

  def self.register(decanter)
    @@decanters[decanter.name] = decanter
  end

  def self.decanter_for(klass_or_sym)
    name = klass_or_sym.is_a?(Class) ?
            klass_or_sym.name :
            klass_or_sym.to_s.singularize.capitalize

    @@decanters["#{name}Decanter"] || (raise NameError.new("unknown decanter #{name}Decanter"))
  end
end

require 'decanter/version'
require 'active_support/inflector'
require 'decanter/base'
require 'decanter/core'
require 'decanter/extensions'
require 'decanter/value_parser'
