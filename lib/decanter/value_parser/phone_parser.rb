module Decanter
  module ValueParser
    class PhoneParser < Base
      REGEX = /(\d|[.])/
      parser do |val, options|
        return val if val.is_a?(Fixnum)
        val.scan(REGEX).join.try(:to_s)
      end
    end
  end
end
