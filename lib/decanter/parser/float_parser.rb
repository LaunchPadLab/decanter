module Decanter
  module Parser
    class FloatParser < ValueParser
      REGEX = /(\d|[.])/

      allow Float, Integer

      parser do |val, _options|
        val.scan(REGEX).join.try(:to_f)
      end
    end
  end
end
