require 'active_support/all'

module Decanter

  @@decanters = {}

  def self.register(decanter)
    @@decanters[decanter.name.demodulize] = decanter
  end

  def self.decanter_for(klass_or_sym)
    name = klass_or_sym.is_a?(Class) ?
            klass_or_sym.name :
            klass_or_sym.to_s.singularize.camelize
    full_name = name.include?('Decanter') ? name : "#{name}Decanter"
    @@decanters[full_name] || (raise NameError.new("unknown decanter #{name}Decanter"))
  end

  ActiveSupport.run_load_hooks(:decanter, self)
end

require 'decanter/version'
require 'decanter/base'
require 'decanter/core'
require 'decanter/extensions'
require 'decanter/value_parser'
require 'decanter/railtie' if defined?(::Rails)
