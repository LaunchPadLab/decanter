module Decanter
  module Parser
    class PhoneParser < Base
      REGEX = /\d/

      allow Fixnum

      parser do |name, val, options|
        val.scan(REGEX).join.to_s
      end
    end
  end
end
