module Decanter
  module ValueParser
    class PhoneParser < Base
      REGEX = /(\d|[.])/

      allow Fixnum

      parser do |val, options|
        val.scan(REGEX).join.try(:to_s)
      end
    end
  end
end
