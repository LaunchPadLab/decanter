require_relative 'core'

# A parser that composes the results of multiple parsers.
# Intended for internal use only.
module Decanter
  module Parser
    class ComposeParser < Base

      def self._parse(name, value, options={})
        raise Decanter::ParseError.new('Must have parsers set') unless @parsers
        # Call each parser on the result of the previous one.
        @parsers.reduce({ name => value }) do |result, parser|
          result.keys.reduce({}) do |acc, key| 
            acc.merge(parser.parse(key, result[key], options)) 
          end
        end
      end

      def self.parsers(parsers)
        @parsers = parsers
      end

    end
  end
end

