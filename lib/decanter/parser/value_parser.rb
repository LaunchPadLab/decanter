require_relative 'core'

module Decanter
  module Parser
    class ValueParser < Base
      def self._parse(name, values, options = {})
        { name => @parser.call(values, options) }
      end
    end
  end
end
