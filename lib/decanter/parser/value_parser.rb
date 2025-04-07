# frozen_string_literal: true

require_relative 'core'

module Decanter
  module Parser
    class ValueParser < Base
      def self._parse(name, value, options = {})
        validate_singularity(value)
        super
      end

      def self.validate_singularity(value)
        raise Decanter::ParseError, 'Expects a single value' if value.is_a? Array
      end
    end
  end
end
