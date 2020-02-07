module Decanter
  module Parser
    class ArrayParser < ValueParser

      DUMMY_NAME = '_'.freeze

      parser do |val, options|
        next if val.nil?
        raise Decanter::ParseError.new 'Expects an array' unless val.is_a? Array
        # Fetch parser classes for provided keys
        parse_each = options.fetch(:parse_each, :pass)
        item_parsers = Parser.parsers_for(Array.wrap(parse_each))
        unless item_parsers.all? { |parser| parser <= ValueParser }
          raise Decanter::ParseError.new 'parser(s) for array items must subclass ValueParser'
        end
        # Compose parsers and apply to all values
        composed_parser = Parser.compose(item_parsers)
        val.map do |item| 
          # Value parsers will expect a "name" for the value they're parsing, 
          # so we provide a dummy one.
          result = composed_parser.parse(DUMMY_NAME, item, options)
          result[DUMMY_NAME]
        end
      end

    end
  end
end
