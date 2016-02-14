module Decanter
  module ValueParser
    @@value_parsers = {}

    def self.register(value_parser)
      @@value_parsers[value_parser.name] = value_parser
    end

    def self.value_parser_for(sym)
      @@value_parsers["#{sym.to_s.capitalize}Parser"] || (raise NameError.new("unknown value parser #{sym.to_s.capitalize}Parser"))
    end
  end
end

require_relative 'value_parser/base'
require_relative 'value_parser/core'
require_relative 'value_parser/boolean_parser'
require_relative 'value_parser/string_parser'
require_relative 'value_parser/date_parser'
