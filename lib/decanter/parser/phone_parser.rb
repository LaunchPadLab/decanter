module Decanter
  module Parser
    class PhoneParser < ValueParser
      REGEX = /\d/

      allow Integer

      parser do |val, _options|
        val.scan(REGEX).join.to_s
      end
    end
  end
end
