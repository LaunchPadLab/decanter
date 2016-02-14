module Decanter
  module ValueParser
    class IntegerParser < Base
      REGEX = /(\d|[.])/

      allow Fixnum

      parser do |val, options|
        return val.to_i if val.is_a?(Float)
        val.scan(REGEX).join.try(:to_i)
      end
    end
  end
end
