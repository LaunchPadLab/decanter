module Decanter
  module Parser
    class ArrayParser < ValueParser

      DUMMY_VALUE_KEY = '_'.freeze

      parser do |val, options|
        next if val.nil?
        raise Decanter::ParseError.new 'Expects an array' unless val.is_a? Array
        # Fetch parser classes for provided keys
        parse_each = options.fetch(:parse_each, :pass)
        item_parsers = Parser.parsers_for(Array.wrap(parse_each))
        unless item_parsers.all? { |parser| parser <= ValueParser }
          raise Decanter::ParseError.new 'parser(s) for array items must subclass ValueParser'
        end
        # Compose supplied parsers
        item_parser = Parser.compose_parsers(item_parsers)
        # Parse all values
        val.map do |item|
          # Value parsers will expect a "key" for the value they're parsing,
          # so we provide a dummy one.
          result = item_parser.parse(DUMMY_VALUE_KEY, item, options)
          result[DUMMY_VALUE_KEY]
        end.compact
      end
    end
  end
end
