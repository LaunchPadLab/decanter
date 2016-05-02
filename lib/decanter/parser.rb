module Decanter
  module Parser

    class << self
      def parsers_for(klass_or_syms)
        Array.wrap(klass_or_syms)
          .map do |klass_or_sym|
            parser_str = case klass_or_sym
            when Class
              klass_or_sym.name
            when Symbol
              klass_or_sym.to_s.singularize.camelize
            else
              raise ArgumentError.new("cannot lookup parser for #{klass_or_sym} with class #{klass_or_sym.class}")
            end.concat('Parser')

            parser = parser_str.safe_constantize || "Decanter::Parser::".concat(parser_str).safe_constantize
            raise NameError.new("cannot find parser #{parser_str}") unless parser
            parser
          end
      end
    end
  end
end

require "#{File.dirname(__FILE__)}/parser/core.rb"
require "#{File.dirname(__FILE__)}/parser/base.rb"
require "#{File.dirname(__FILE__)}/parser/value_parser.rb"
require "#{File.dirname(__FILE__)}/parser/hash_parser.rb"
Dir["#{File.dirname(__FILE__)}/parser/*_parser.rb"].each { |f| require f }
