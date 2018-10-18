# frozen_string_literal: true

require_relative 'core'

module Decanter
  module Parser
    class ValueParser < Base
      def self._parse(values, options = {})
        @parser.call(values, options)
      end
    end
  end
end
