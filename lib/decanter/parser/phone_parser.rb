module Decanter
  module Parser
    class PhoneParser < ValueParser
      REGEX = /\d/

      allow Fixnum

      parser do |val, options|
        val.scan(REGEX).join.to_s
      end
    end
  end
end
