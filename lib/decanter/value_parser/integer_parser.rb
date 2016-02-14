module Decanter
  module ValueParser
    class IntegerParser < Base
      REGEX = /(\d|[.])/

      allow Fixnum

      parser do |name, val, options|
        val.is_a?(Float) ?
          val.to_i :
          val.scan(REGEX).join.try(:to_i)
      end
    end
  end
end
