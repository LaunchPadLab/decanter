# frozen_string_literal: true

require 'active_support/all'

module Decanter
  class << self
    def decanter_for(klass_or_sym)
      decanter_name =
        case klass_or_sym
        when Class
          klass_or_sym.name
        when Symbol
          klass_or_sym.to_s.singularize.camelize
        else
          raise ArgumentError, "cannot lookup decanter for #{klass_or_sym} with class #{klass_or_sym.class}"
        end + 'Decanter'
      decanter_name.constantize
    end

    def decanter_from(klass_or_string)
      constant =
        case klass_or_string
        when Class
          klass_or_string
        when String
          klass_or_string.constantize
        else
          raise ArgumentError, "cannot find decanter from #{klass_or_string} with class #{klass_or_string.class}"
        end

      unless constant.ancestors.include? Decanter::Base
        raise ArgumentError, "#{constant.name} is not a decanter"
      end

      constant
    end

    def configuration
      @configuration ||= Decanter::Configuration.new
    end

    def config
      yield configuration
    end
  end

  ActiveSupport.run_load_hooks(:decanter, self)
end

require 'decanter/version'
require 'decanter/configuration'
require 'decanter/core'
require 'decanter/base'
require 'decanter/extensions'
require 'decanter/exceptions'
require 'decanter/parser'
require 'decanter/railtie' if defined?(::Rails)
