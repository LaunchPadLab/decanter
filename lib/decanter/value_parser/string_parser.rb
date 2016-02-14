module Decanter
  module ValueParser
    class StringParser < Base

      allow String

      parser do |name, val, options|
        val.to_s
      end
    end
  end
end
