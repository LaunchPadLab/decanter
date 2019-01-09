# frozen_string_literal: true

module Decanter
  module Parser
    class FloatParser < ValueParser
      allow Float

      parser do |val, _options|
        Float(val)
      end
    end
  end
end
