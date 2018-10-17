# frozen_string_literal: true

require_relative 'core'

module Decanter
  module Parser
    class HashParser < Base
      def self._parse(name, values, options = {})
        { name => validate_hash(@parser.call(name, values, options)) }
      end

      def self.validate_hash(parsed)
        return parsed if parsed.is_a?(Hash)

        raise(ArgumentError, "Result of HashParser #{name} was #{parsed} when it must be a hash.")
      end

      private_class_method :validate_hash
    end
  end
end
