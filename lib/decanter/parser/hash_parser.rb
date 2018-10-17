# frozen_string_literal: true

require_relative 'core'
require 'pp'

module Decanter
  module Parser
    class HashParser < Base
      def self._parse(values, options = {})
        validate_hash(@parser.call(values, options))
      end

      def self.validate_hash(parsed)
        return parsed if parsed.is_a?(Hash)

        raise(ArgumentError, "Result of HashParser was #{parsed} when it must be a hash.")
      end

      private_class_method :validate_hash
    end
  end
end
