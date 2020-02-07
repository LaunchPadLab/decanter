module Decanter
  module Parser
    class ArrayParser < ValueParser

      parser do |val, options|
        next if val.nil?
        raise Decanter::ParseError.new 'Expects an array' unless val.is_a? Array
        parse_each = options.fetch(:parse_each, :pass)
        # Fetch parser classes for provided keys
        item_parsers = Parser.parsers_for(Array.wrap(parse_each))
        validate_item_parsers!(item_parsers)
        val.map { |item| apply_parsers(item, item_parsers) }
      end

      # Helpers

      class << self

        private

        # Make sure all parsers subclass ValueParser
        def validate_item_parsers!(parsers)
          return if parsers.all? { |parser| parser <= ValueParser }
          raise Decanter::ParseError.new 'parser(s) for array items must subclass ValueParser'
        end

        # Parse a value with multiple parsers.
        # This is simpler than the merge algorithm in Decanter::Core
        # because it only expects ValueParser parsers.
        def apply_parsers(value, parsers)
          parsers.reduce(value) { |current_value, parser| apply_parser(current_value, parser) }
        end

        # Parse a single value with a value parser.
        # Nested parsers will expect a "name" for the value they're parsing, 
        # so we provide a dummy one.
        def apply_parser(value, parser)
          result_hash = parser.parse('', value)
          result_hash['']
        end

      end

    end
  end
end
