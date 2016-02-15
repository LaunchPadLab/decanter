module Decanter
  module ValueParser
    @@value_parsers = {}

    def self.register(value_parser)
      @@value_parsers[value_parser.name.demodulize] = value_parser
    end

    def self.value_parser_for(sym)
      p "find parser for #{sym}"
      @@value_parsers["#{sym.to_s.camelize}Parser"] || (raise NameError.new("unknown value parser #{sym.to_s.capitalize}Parser"))
    end
  end
end

require_relative 'value_parser/base'
require_relative 'value_parser/core'
require_relative 'value_parser/boolean_parser'
require_relative 'value_parser/date_parser'
require_relative 'value_parser/datetime_parser'
require_relative 'value_parser/string_parser'
require_relative 'value_parser/phone_parser'
require_relative 'value_parser/float_parser'
require_relative 'value_parser/integer_parser'
require_relative 'value_parser/key_value_splitter_parser'
