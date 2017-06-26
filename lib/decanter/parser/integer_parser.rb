module Decanter
  module Parser
    class IntegerParser < ValueParser
      REGEX = /(\d|[.])/

      allow Integer

      parser do |val, options|
        val.is_a?(Float) ?
          val.to_i :
          val.scan(REGEX).join.try(:to_i)
      end
    end
  end
end
