module Decanter
  module Parser
    class FloatParser < ValueParser
      REGEX = /(\d|[.])/

      allow Float, Integer

      parser do |val, options|
        val.scan(REGEX).join.try(:to_f)
      end
    end
  end
end
