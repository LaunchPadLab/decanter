require_relative 'core'

module Decanter
  module Parser
    class HashParser < Base
      def self._parse(name, values, options={})
        validate_hash(@parser.call(name, values, options))
      end

      private
      def self.validate_hash(parsed)
        parsed.is_a?(Hash) ? parsed :
          raise(ArgumentError.new("Result of HashParser #{self.name} was #{parsed} when it must be a hash."))
      end
    end
  end
end

