module Decanter
  module ValueParser

    class << self
      def parser_for(klass_or_sym)
        case klass_or_sym
        when Class
          klass_or_sym.name
        when Symbol
          klass_or_sym.to_s.singularize.camelize
        else
          raise ArgumentError.new("cannot lookup parser for #{klass_or_sym} with class #{klass_or_sym.class}")
        end.concat('Parser').constantize
      end
    end
  end
end

Dir["#{File.dirname(__FILE__)}/value_parser/*.rb"].each { |f| require f }
