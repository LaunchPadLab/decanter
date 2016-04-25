require_relative 'core'

module Decanter
  module Parser
    class ValueParser < Base
      def self.parse(name, values, options={})
        super || { name => @parser.call(values, options) }
      end
    end
  end
end

