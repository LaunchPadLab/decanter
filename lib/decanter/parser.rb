module Decanter
  module Parser
    class << self
      def parsers_for(klass_or_syms)
        Array.wrap(klass_or_syms)
             .map { |klass_or_sym| klass_or_sym_to_str(klass_or_sym) }
             .map { |parser_str|   parser_constantize(parser_str) }
             .map { |parser|       expand(parser) }
             .flatten
      end

      # convert from a class or symbol to a string and concat 'Parser'
      def klass_or_sym_to_str(klass_or_sym)
        case klass_or_sym
        when Class
          klass_or_sym.name
        when Symbol
          symbol_to_string(klass_or_sym)
        else
          raise ArgumentError.new("cannot lookup parser for #{klass_or_sym} with class #{klass_or_sym.class}")
        end.concat('Parser')
      end

      # convert from a string to a constant
      def parser_constantize(parser_str)
        # safe_constantize returns nil if match not found
        parser_str.safe_constantize ||
          concat_str(parser_str).safe_constantize ||
          raise(NameError.new("cannot find parser #{parser_str}"))
      end

      # extract string transformation strategies
      def symbol_to_string(klass_or_sym)
        if singular_class_present?(klass_or_sym)
          singularize_and_camelize_str(klass_or_sym)
        else
          camelize_str(klass_or_sym)
        end
      end

      def singular_class_present?(klass_or_sym)
        parser_str = singularize_and_camelize_str(klass_or_sym)
        concat_str(parser_str).safe_constantize.present?
      end

      def singularize_and_camelize_str(klass_or_sym)
        klass_or_sym.to_s.singularize.camelize
      end

      def camelize_str(klass_or_sym)
        klass_or_sym.to_s.camelize
      end

      def concat_str(parser_str)
        "Decanter::Parser::".concat(parser_str)
      end

      # expand to include preparsers
      def expand(parser)
        Parser.parsers_for(parser.preparsers).push(parser)
      end
    end
  end
end

require "#{File.dirname(__FILE__)}/parser/core.rb"
require "#{File.dirname(__FILE__)}/parser/base.rb"
require "#{File.dirname(__FILE__)}/parser/value_parser.rb"
require "#{File.dirname(__FILE__)}/parser/hash_parser.rb"
Dir["#{File.dirname(__FILE__)}/parser/*_parser.rb"].each { |f| require f }
