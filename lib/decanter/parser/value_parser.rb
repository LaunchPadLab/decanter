require_relative 'core'

module Decanter
  module Parser
    class ValueParser < Base

      def self._parse(name, value, options={})
        self.validate_singularity(value)
        super(name, value, options)
      end

      def self.validate_singularity(value)
        raise Decanter::ParseError.new 'Expects a single value' if value.is_a? Array
      end
    end
  end
end

