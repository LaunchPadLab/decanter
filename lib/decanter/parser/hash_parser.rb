# frozen_string_literal: true

require_relative 'core'

module Decanter
  module Parser
    class HashParser < Base
      def self._parse(name, value, options = {})
        validate_hash(@parser.call(name, value, options))
      end

      def self.validate_hash(parsed)
        unless parsed.is_a?(Hash)
          raise ArgumentError,
                "Result of HashParser #{name} was #{parsed} when it must be a hash."
        end

        parsed
      end
    end
  end
end
