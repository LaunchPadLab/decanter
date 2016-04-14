module Decanter
  module ValueParser

    class << self
      def parser_for(klass_or_sym)
        parser_str = case klass_or_sym
        when Class
          klass_or_sym.name
        when Symbol
          klass_or_sym.to_s.singularize.camelize
        else
          raise ArgumentError.new("cannot lookup parser for #{klass_or_sym} with class #{klass_or_sym.class}")
        end.concat('Parser')
        parser_str.safe_constantize ||
        ("Decanter::ValueParser::" + parser_str).safe_constantize ||
        raise ArgumentError.new("cannot find parser #{parser_str}")
      end
    end
  end
end

require "#{File.dirname(__FILE__)}/value_parser/core.rb"
require "#{File.dirname(__FILE__)}/value_parser/base.rb"
Dir["#{File.dirname(__FILE__)}/value_parser/*_parser.rb"].each { |f| require f }
