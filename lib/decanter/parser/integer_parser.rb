# frozen_string_literal: true

module Decanter
  module Parser
    class IntegerParser < ValueParser
      allow Integer

      parser do |val, _options|
        Integer(val)
      end
    end
  end
end
