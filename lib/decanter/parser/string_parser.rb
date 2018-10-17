# frozen_string_literal: true

module Decanter
  module Parser
    class StringParser < ValueParser
      allow String

      parser do |val, _options|
        val.to_s
      end
    end
  end
end
