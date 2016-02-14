module Decanter
  module ValueParser
    class FloatParser < Base
      REGEX = /(\d|[.])/

      allow Float, Fixnum

      parser do |name, val, options|
        val.scan(REGEX).join.try(:to_f)
      end
    end
  end
end
