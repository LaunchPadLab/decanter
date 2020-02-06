require_relative 'core'

module Decanter
  module Parser
    class ValueParser < Base
      def self._parse(name, value, options={})
        { name => @parser.call(value, options) }
      end
    end
  end
end

